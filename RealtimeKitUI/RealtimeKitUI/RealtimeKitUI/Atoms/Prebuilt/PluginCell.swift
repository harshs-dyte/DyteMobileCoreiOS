//
//  PluginCell.swift
//  RealtimeKitUI
//
//  Created by Shaunak Jagtap on 24/01/23.
//

import UIKit
import RealtimeKitCore

class PluginCell: UITableViewCell {
    
    var pluginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(plugin: RtkPlugin, indexPath: IndexPath) {
        self.nameLabel.text = plugin.name
        if #available(iOS 13.0, *) {
            self.launchImageView.image = ImageProvider.image(named: plugin.isActive == false ? "icon_plugin" : "icon_cross")?.withTintColor(DesignLibrary.shared.color.brand.shade500, renderingMode: .alwaysTemplate)
        } else {
            // Fallback on earlier versions
            let image = ImageProvider.image(named: plugin.isActive == false ? "icon_plugin" : "icon_cross")
            let templateImage = image?.withRenderingMode(.alwaysTemplate)
            self.launchImageView.image = templateImage
            self.tintColor = DesignLibrary.shared.color.brand.shade500
           
        }
        let result = ImageUtil.shared.obtainImageWithPath(imagePath: plugin.picture , completionHandler: { [weak self] image, url in
            self?.pluginImageView.image = image
        })
        if let image = result.0 {
            self.pluginImageView.image = image
        }
        if plugin.isActive {
            self.accessibilityIdentifier = "Plugin_\(plugin.name)_IsActive"
        }else {
            self.accessibilityIdentifier = "Plugin_\(plugin.name)_IsInActive"
        }
    }
    
    
    // MARK: - Setup Views
    func setupView() {
        contentView.addSubview(pluginImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(launchImageView)
        pluginImageView.set(.top(contentView, 10, .greaterThanOrEqual),
                            .centerY(contentView),
                            .leading(contentView, 10),
                            .width(40),
                            .height(40))
        launchImageView.set(.centerY(pluginImageView),
                            .trailing(contentView, 10),
                            .height(20),
                            .width(20))
        nameLabel.set(.centerY(pluginImageView),
                      .top(contentView, 0.0, .greaterThanOrEqual),
                      .after(pluginImageView, 10),
                      .before(launchImageView, 10))
    }
}

