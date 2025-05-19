//
//  DocumentsViewController.swift
//  RealtimeKitUI
//
//  Created by Shaunak Jagtap on 09/06/23.
//

import UIKit
import QuickLook

class DocumentsViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    private let documentURL: URL
    private let previewController = QLPreviewController()
    var downloadFinishAction: (() -> Void)?
    
    init(documentURL: URL) {
        self.documentURL = documentURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewController.dataSource = self
        previewController.delegate = self
        title = "Documents"
        
        // Download the file if needed
        downloadFileIfNeeded()
    }
    
    private func downloadFileIfNeeded() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(documentURL.lastPathComponent)
        
        if !fileManager.fileExists(atPath: destinationURL.path) {
            FileDownloader.downloadFile(from: documentURL, to: destinationURL) { [weak self] success, error in
                self?.downloadFinishAction?()
                if success {
                    print("File downloaded successfully.")
                    DispatchQueue.main.async {
                        self?.openDocument()
                    }
                } else if let error = error {
                    print("Error while downloading file: \(error)")
                }
            }
        } else {
            self.downloadFinishAction?()
            openDocument()
        }
    }
    
    private func openDocument() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(documentURL.lastPathComponent)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            DispatchQueue.main.async {
                self.previewController.reloadData()
                self.present(self.previewController, animated: true, completion: nil)
            }
        } else {
            print("Unable to present QLPreviewController. The file doesn't exist.")
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(documentURL.lastPathComponent)
        return fileURL as QLPreviewItem
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.dismiss(animated: false)
    }

}
