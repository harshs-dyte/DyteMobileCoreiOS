//
//  PluginViewController.swift
//  RealtimeKitUI
//
//  Created by Shaunak Jagtap on 24/01/23.
//

import Foundation
import RealtimeKitCore
import UIKit

public class RtkPluginViewController: UIViewController {
    
    // MARK: - Properties
    var plugins: [RtkPlugin] = []
    let pluginTableView = UITableView()
    
    public init(plugins: [RtkPlugin]) {
        self.plugins = plugins
        if plugins.count > 0 {
            pluginTableView.accessibilityIdentifier = "Plugins_List"
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    public  override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.view.accessibilityIdentifier = "Plugins_Screen"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
   private func setupViews() {
        
        // configure messageTableView
        pluginTableView.delegate = self
        pluginTableView.keyboardDismissMode = .onDrag
        pluginTableView.dataSource = self
        pluginTableView.register(PluginCell.self, forCellReuseIdentifier: "PluginCell")
        pluginTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pluginTableView)
    
        let leftButton: RtkControlBarButton = {
            let button = RtkControlBarButton(image: RtkImage(image: ImageProvider.image(named: "icon_cross")))
            return button
        }()
        leftButton.backgroundColor = navigationItem.backBarButtonItem?.tintColor
        leftButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = customBarButtonItem
        
        let label = RtkUIUTility.createLabel(text: "Plugins")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = DesignLibrary.shared.color.textColor.onBackground.shade900
        navigationItem.titleView = label
        // add constraints
        let constraints = [
            pluginTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pluginTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pluginTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pluginTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: - Actions
    @objc func goBack() {
        self.dismiss(animated: true)
    }
}

extension RtkPluginViewController: UITableViewDelegate, UITableViewDataSource {
  public  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plugins.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PluginCell", for: indexPath) as? PluginCell
        {
            cell.set(plugin: plugins[indexPath.row], indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell(frame: .zero)
    }
    
    public   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plugin = plugins[indexPath.row]
        if plugin.isActive {
            plugin.deactivate()
        }else {
            plugin.activate() 
        }
        goBack()
    }
}
