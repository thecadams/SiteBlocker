//
//  ViewController.swift
//  SiteBlocker
//
//  Created by Chris Adams on 4/17/18.
//  Copyright © 2018 cadams. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBlockedSite(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Add blocked site

    @objc func addBlockedSite(_ sender: Any) {
        let addItemController = UIAlertController.init(title: "Add regex", message: "Enter regex to block", preferredStyle: .alert)
        addItemController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "^https://(www.)?google.com/"
        })
        addItemController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let context = self.fetchedResultsController.managedObjectContext
            let entry = Entry(context: context)
            entry.enabled = true
            let url = addItemController.textFields?[0].text
            entry.url = url

            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error saving url \(String(describing: url)): \(nserror), \(nserror.userInfo)")
            }
        }))
        addItemController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(addItemController, animated: true, completion: nil)
    }

    // MARK: - Cell editing

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = self.fetchedResultsController.object(at: indexPath)
        let editItemController = UIAlertController.init(title: "Edit regex", message: "Enter regex to block", preferredStyle: .alert)
        editItemController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "^https://(www.)?google.com/"
            textField.text = entry.url
        })
        editItemController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let url = editItemController.textFields?[0].text
            entry.url = url

            let context = self.fetchedResultsController.managedObjectContext
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error saving url \(String(describing: url)): \(nserror), \(nserror.userInfo)")
            }
        }))
        editItemController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(editItemController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let entry = self.fetchedResultsController.object(at: indexPath)
        entry.enabled = !entry.enabled
        let context = self.fetchedResultsController.managedObjectContext
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error saving entry \(String(describing: entry)): \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEntry: entry)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))

            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEntry entry: Entry) {
        cell.textLabel!.text = entry.url
        let checkmarkButton = (cell.subviews.first { $0 as? UIButton != nil } as? UIButton)!
        checkmarkButton.setImage(checkImage, for: .normal)
        checkmarkButton.isSelected = entry.enabled
    }

    lazy var checkImage: UIImage = {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }()

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Entry> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }

        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()

        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Entry>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEntry: anObject as! Entry)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEntry: anObject as! Entry)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
