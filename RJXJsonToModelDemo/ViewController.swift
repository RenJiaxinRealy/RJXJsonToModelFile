//
//  ViewController.swift
//  RJXJsonToModelDemo
//
//  Created by Jin Rookie on 2026/3/5.
//

import UIKit

class ViewController: UIViewController {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let modelNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Model 名称（如：User）"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let convertButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("转换为 Model", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()

        // 仅在模拟器下运行
        #if !targetEnvironment(simulator)
        convertButton.isEnabled = false
        convertButton.alpha = 0.5
        statusLabel.text = "此功能仅在模拟器下可用"
        statusLabel.textColor = .systemOrange
        #endif
    }

    private func setupUI() {
        title = "JSON 转 Model 工具"

        view.addSubview(textView)
        view.addSubview(modelNameField)
        view.addSubview(convertButton)
        view.addSubview(statusLabel)

        textView.text = """
        请在此粘贴 JSON 字符串：

        示例：
        {
            "user_id": 123,
            "user_name": "John",
            "email": "john@example.com",
            "age": 30,
            "is_active": true,
            "profile": {
                "bio": "Developer",
                "avatar_url": "https://example.com/avatar.png"
            },
            "tags": ["ios", "swift"]
        }
        """

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 300),

            modelNameField.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            modelNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modelNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            convertButton.topAnchor.constraint(equalTo: modelNameField.bottomAnchor, constant: 16),
            convertButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        convertButton.addTarget(self, action: #selector(convertTapped), for: .touchUpInside)
    }

    @objc private func convertTapped() {
        let jsonString = textView.text ?? ""
        let modelName = modelNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !modelName.isEmpty else {
            statusLabel.text = "请输入 Model 名称"
            statusLabel.textColor = .systemRed
            return
        }

        guard !jsonString.isEmpty else {
            statusLabel.text = "请输入 JSON 字符串"
            statusLabel.textColor = .systemRed
            return
        }

        do {
            _ = try JsonToModel.convert(jsonString, to: modelName)
            statusLabel.text = "✓ Model 文件已生成并保存到:\n~/Desktop/RJXJsonToModelFile-Workspace/\(modelName).swift"
            
            statusLabel.textColor = .systemGreen
        } catch {
            statusLabel.text = "错误：\(error.localizedDescription)"
            statusLabel.textColor = .systemRed
        }
    }
}

