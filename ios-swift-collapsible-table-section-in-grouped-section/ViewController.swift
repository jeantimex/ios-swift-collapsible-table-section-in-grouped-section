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

    var sections = [Section]()
    
    //Items to keep at the top of each section
    //if a section items count less than this value the section does not collapse
    let itemsToKeepAtTheTop     : Int     = 3
    let sectionHeaderCellHeight : CGFloat = 50.0
    let cellHeight              : CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the sections array
        // Here we have three sections: Mac, iPad, iPhone
        sections = [
            Section(name: "Mac",
                    items: ["MacBook",
                            "MacBook Air",
                            "MacBook Pro", "iMac",
                            "Mac Pro", "Mac mini",
                            "Accessories",
                            "OS X El Capitan"],
                    collapsed:  true),
            Section(name: "iPad", items: ["iPad Pro",
                                          "iPad Air 2",
                                          "iPad mini 4",
                                          "Accessories"],
                    collapsed: true),
            Section(name: "iPhone", items: ["iPhone 6s",
                                            "iPhone 6",
                                            "iPhone SE",
                                            "Accessories"],
                    collapsed: true)
        ]
    }

    //
    // MARK: - Table view delegate
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:  return "Manufacture"
            case 1:  return "Products"
            default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.rowHeight
        }
        
        // Calculate the real section index and row index
        let section = sections.getSectionIndex(indexPath.row)
        let row = sections.getRowIndex(indexPath.row)
        
        // Header has fixed height
        if row == 0 { return sectionHeaderCellHeight }
                
        if sections[section].collapsed! {
            var count = 0
            var itemsToHide = 0
            var needsToHideEntireSection = false
            for index in 0...section {
                count += sections[index].items.count
                needsToHideEntireSection = itemsToKeepAtTheTop >= sections[index].items.count
                itemsToHide = sections[index].items.count - (sections[index].items.count + (sections[index].items.count - itemsToKeepAtTheTop) - 1)
            }
            if needsToHideEntireSection {
                return cellHeight
            } else {
                return indexPath.row < count + section + itemsToHide ? cellHeight : 0
            }
        } else {
            return cellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title")
            cell?.textLabel?.text = "Apple"
            return cell!
        }
        
        // Calculate the real section index and row index
        let section = sections.getSectionIndex(indexPath.row)
        let row = sections.getRowIndex(indexPath.row)
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderCell
            cell.titleLabel.text = sections[section].name
            cell.toggleButton.tag = section
            cell.toggleButton.setTitle(sections[section].collapsed! ? "+" : "-", for: UIControl.State())
            cell.toggleButton.addTarget(self, action: #selector(ViewController.toggleCollapse), for: .touchUpInside)
            cell.countLabel.text = "\(sections[section].items.count - itemsToKeepAtTheTop)+"
            cell.countLabel.isHidden = !sections[section].collapsed
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = sections[section].items[row - 1]
            return cell!
        }
    }
    
    //
    // MARK: - Event Handlers
    //
    @objc func toggleCollapse(_ sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed!
        
        let indices = sections.getHeaderIndices()
        
        let start = indices[section]
        let end = start + sections[section].items.count
        
        tableView.beginUpdates()
        for i in start ..< end + 1 {
            tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
        }
        tableView.endUpdates()
    }
}

struct Section {
    var name: String!
    var items: [String]!
    var collapsed: Bool!
    init(name: String, items: [String], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

extension Array where Element == Section {
    func getRowIndex(_ row: NSInteger) -> Int {
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
    
    func getSectionIndex(_ row: NSInteger) -> Int {
        let indices = self.getHeaderIndices()
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                return i
            }
        }
        return -1
    }
    
    func getHeaderIndices() -> [Int] {
        var index = 0
        var indices: [Int] = []
        for section in self {
            indices.append(index)
            index += section.items.count + 1
        }
        
        return indices
    }
}
