//
//  ViewController.swift
//  ios-swift-collapsible-table-section-in-grouped-section
//
//  Created by Yong Su on 5/31/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    //
    // MARK: - Data
    //
    
    struct Section {
        var name: String!
        var items: [String]!
        var collapsed: Bool!
        
        init(name: String, items: [String]) {
            self.name = name
            self.items = items
            self.collapsed = true
        }
    }
    
    var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the sections array
        // Here we have three sections: Mac, iPad, iPhone
        sections = [
            Section(name: "Mac", items: ["MacBook", "MacBook Air", "MacBook Pro", "iMac", "Mac Pro", "Mac mini", "Accessories", "OS X El Capitan"]),
            Section(name: "iPad", items: ["iPad Pro", "iPad Air 2", "iPad mini 4", "Accessories"]),
            Section(name: "iPhone", items: ["iPhone 6s", "iPhone 6", "iPhone SE", "Accessories"])
        ]
    }

    //
    // MARK: - Table view delegate
    //
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:  return "Manufacture"
            case 1:  return "Products"
            default: return ""
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        // For section 1, the total count is items count plus the number of headers
        var count = sections.count
        
        for section in sections {
            count += section.items.count
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.rowHeight
        }
        
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        
        // Header has fixed height
        if row == 0 {
            return 50.0
        }
        
        return sections[section].collapsed! ? 0 : 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("title") as UITableViewCell!
            cell.textLabel?.text = "Apple"
            return cell
        }
        
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("header") as! HeaderCell
            cell.titleLabel.text = sections[section].name
            cell.toggleButton.tag = section
            cell.toggleButton.setTitle(sections[section].collapsed! ? "+" : "-", forState: .Normal)
            cell.toggleButton.addTarget(self, action: #selector(ViewController.toggleCollapse), forControlEvents: .TouchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
            cell.textLabel?.text = sections[section].items[row - 1]
            return cell
        }
    }
    
    //
    // MARK: - Event Handlers
    //
    func toggleCollapse(sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed
        
        let indices = getHeaderIndices()
        
        let start = indices[section]
        let end = start + sections[section].items.count
        
        tableView.beginUpdates()
        for i in start ..< end + 1 {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 1)], withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
    }
    
    //
    // MARK: - Helper Functions
    //
    func getSectionIndex(row: NSInteger) -> Int {
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                return i
            }
        }
        
        return -1
    }
    
    func getRowIndex(row: NSInteger) -> Int {
        var index = row
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                index -= indices[i]
                break
            }
        }
        
        return index
    }
    
    func getHeaderIndices() -> [Int] {
        var index = 0
        var indices: [Int] = []
        
        for section in sections {
            indices.append(index)
            index += section.items.count + 1
        }
        
        return indices
    }

}
