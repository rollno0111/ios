import UIKit
import MessageUI

class SettingsViewController: BaseUITableViewController, MFMailComposeViewControllerDelegate {
    
    var settingItems = StringLiterals.SETTINGS_ACTION_TITLES
    var titleForSections = StringLiterals.SETTINGS_SECTION_TITLES
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func showAlert(with title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
        })
        self.present(alertController, animated: true)
    }
    
    func configureMailComposeViewController(recipient: String,
                                            subject: String,
                                            message: String) ->MFMailComposeViewController {
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([recipient])
        mail.setSubject(subject)
        mail.setMessageBody(message, isHTML: true)
        
        return mail
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController,
                               didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
            case .cancelled:
                let myalert = UIAlertController(title: StringLiterals.CANCEL_TITLE, message: StringLiterals.CANCEL_MESSAGE, preferredStyle: UIAlertController.Style.alert)
                
                myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                })
                self.present(myalert, animated: true)
            case .saved:
                let myalert = UIAlertController(title: StringLiterals.SAVED_TITLE, message: StringLiterals.SAVED_MESSAGE, preferredStyle: UIAlertController.Style.alert)
                
                myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                })
                self.present(myalert, animated: true)
            case .sent:
                let myalert = UIAlertController(title: StringLiterals.SENT_TITLE, message: StringLiterals.SENT_MESSAGE, preferredStyle: UIAlertController.Style.alert)
                
                myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                })
                self.present(myalert, animated: true)
            
            case .failed:
                AmahiLogger.log("Mail sent failure: \(String(describing: error?.localizedDescription))")
                // default:
                break
        }
        self.dismiss(animated: true, completion: nil)
    }
    // MARK:- Signout function Added
    
    func signOut() {
        self.dismiss(animated: false, completion: nil)
        LocalStorage.shared.logout {}
        let loginVc = self.viewController(viewControllerClass: LoginViewController.self, from: StoryBoardIdentifiers.MAIN)
        self.present(loginVc, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titleForSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForSections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        var cell: UITableViewCell
        
        if section == 1 || (section == 2 && row == 0) {
        
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.SETTING_CELL_WITH_DETAILS, for: indexPath)
            cell.textLabel?.text = settingItems[section][row]
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            if section == 1 && row == 0 {
                let connectionMode = LocalStorage.shared.userConnectionPreference
                
                if connectionMode == ConnectionMode.auto {
                    let isLocalInUse = ConnectionModeManager.shared.isLocalInUse()
                    
                    if isLocalInUse {
                        cell.detailTextLabel?.text =  StringLiterals.AUTO_CONNECTION_LAN
                    } else {
                        cell.detailTextLabel?.text =  StringLiterals.AUTO_CONNECTION_REMOTE
                    }
                } else {
                  cell.detailTextLabel?.text =  LocalStorage.shared.userConnectionPreference.rawValue
                }
            }
            else if section == 1 && row == 1 {
                
                let cacheFolderPath = FileManager.default.temporaryDirectory.appendingPathComponent("cache").path
                
                let cacheSize = FileManager.default.folderSizeAtPath(path: cacheFolderPath)
                cell.detailTextLabel?.text = String(format: StringLiterals.CURRENT_SIZE, ByteCountFormatter().string(fromByteCount: cacheSize))
            }
            else if section == 2 && row == 0 {
                if let versionNumber = Bundle.main.object(forInfoDictionaryKey: StringLiterals.INFO_DICTIONARY_KEY) as! String? {
                    cell.detailTextLabel?.text = "v\(versionNumber)"
                }
            }
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.SETTING_CELL, for: indexPath)
            cell.textLabel?.text = settingItems[section][row]
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
            
            case 0:
                let refreshAlert = UIAlertController(title: StringLiterals.SIGNOUT_TITLE,
                                                     message:StringLiterals.SIGNOUT_MESSAGE,
                                                     preferredStyle: UIAlertController.Style.alert)
                refreshAlert.addAction(UIAlertAction(title: StringLiterals.CONFIRM,
                                                     style: .destructive, handler: { (action: UIAlertAction!) in
                    self.signOut()
                }))
                refreshAlert.addAction(UIAlertAction(title: StringLiterals.CANCEL, style: .default, handler: { (action: UIAlertAction!) in
                    refreshAlert .dismiss(animated: true, completion: nil)
                }))
                present(refreshAlert, animated: true, completion: nil)
                break
            case 1:
                if row == 0 {
                    performSegue(withIdentifier: SegueIdentfiers.CONNECTION, sender: nil)
                } else if row == 1 {
                    // Clear temp storage
                    
                    let clearCacheAlert = UIAlertController(title: StringLiterals.CLEAR_CACHE_TITLE,
                                                         message:StringLiterals.CLEAR_CACHE_MESSAGE,
                                                         preferredStyle: UIAlertController.Style.alert)
                    clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.CONFIRM,
                                                         style: .destructive, handler: { (action: UIAlertAction!) in
                                                            
                                FileManager.default.deleteFolder(in: FileManager.default.temporaryDirectory,
                                                                                             folderName: "cache")
                                self.tableView.reloadData()
                    }))
                    clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.CANCEL, style: .default, handler: { (action: UIAlertAction!) in
                        clearCacheAlert .dismiss(animated: true, completion: nil)
                    }))
                    present(clearCacheAlert, animated: true, completion: nil)
                }
                
                break
            case 2: 
                if row == 1 {
                    let urlStr = StringLiterals.URL
                    if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                } else if row == 2 {
                    let mailVc = configureMailComposeViewController(recipient: StringLiterals.FEEDBACK_RECEPIENT,
                                                                    subject: StringLiterals.FEEDBACK_SUBJECT,
                                                                    message: StringLiterals.FEEDBACK_MSG)
                    if MFMailComposeViewController.canSendMail() {
                        self.present(mailVc, animated: true, completion: nil)
                    } else {
                        self.showAlert(with: StringLiterals.MAIL_ERROR_TITLE, message: StringLiterals.MAIL_ERROR_MESSAGE)
                    }
                } else if row == 3 {
                    if let name = URL(string: "https://itunes.apple.com/us/app/myapp/id\(StringLiterals.APP_ID)?ls=1&mt=8"), !name.absoluteString.isEmpty {
                        let objectsToShare = [name]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                        self.present(activityVC, animated: true, completion: nil)
                    } else  {
                        self.showAlert(with: StringLiterals.SHARE_ERROR_TITLE, message: StringLiterals.SHARE_ERROR_MESSAGE)
                    }
                }
                break
            default:
                break
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
