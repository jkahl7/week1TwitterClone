//
//  mainViewController.swift
//  TwitterClonePartDeux
//
//  Created by Josh Kahl on 1/18/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var tweets = [Tweet]()
  
  var netController = NetController()
  

  @IBOutlet weak var tableView: UITableView!
  
  override func loadView() {
    super.loadView()
    println("congrats on not crashing")
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.netController.fetchMainTwitterContent()
    
  }
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as UITableViewCell
    
    cell.textLabel?.text = "blank cell"
    
    return cell
  }

}
