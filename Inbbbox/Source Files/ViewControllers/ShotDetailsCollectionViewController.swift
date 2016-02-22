//
//  ShotDetailsCollectionViewController.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 05.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

protocol ShotDetailsCollectionViewControllerDelegate: class {
    func didFinishPresentingDetails(sender: ShotDetailsCollectionViewController)
}

class ShotDetailsCollectionViewController: UICollectionViewController {
    
    weak var delegate: ShotDetailsCollectionViewControllerDelegate?
    
    var localStorage = ShotsLocalStorage()
    var userStorageClass = UserStorage.self
    var shotsRequesterClass =  ShotsRequester()
    
    private let commentsProvider = CommentsProvider(page: 1, pagination: 10)
    
    private var header = ShotDetailsHeaderView()
    private var footer = ShotDetailsFooterView()
    
    private var shot: Shot?
    private var comments: [Comment]?
    private let changingHeaderStyleCommentsThreshold = 3
    
    convenience init(shot: Shot) {
        self.init(collectionViewLayout: ShotDetailsCollectionViewFlowLayout())
        self.shot = shot
        
        setupSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstly {
            self.commentsProvider.provideCommentsForShot(shot!)
        }.then { comments -> Void in
            self.comments = comments ?? []
            self.collectionView?.reloadData()
        }.error { error in
            // NGRTemp: Need mockups for error message view
            print(error)
        }
    }
    
    // MARK: UICollectionViewController DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let comments = comments else { return 0 }
        
        // NGRFix: interesting '>='? added because of problem when somebody adds comment between shot loading and comments loading
        return comments.count >= Int(shot!.commentsCount) ? comments.count : comments.count + 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < comments!.count {
            
            // NGRTodo: refactor needed
            let cell = collectionView.dequeueReusableClass(ShotDetailsCollectionViewCell.self, forIndexPath: indexPath, type: .Cell)
            
            let comment = comments![indexPath.item]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            dateFormatter.timeStyle = .ShortStyle
            
            cell.viewData = ShotDetailsCollectionViewCell.ViewData(
                avatar: comment.user.avatarString!,
                author: comment.user.name ?? comment.user.username,
                comment: comment.body?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString(),
                time: dateFormatter.stringFromDate(comment.createdAt)
            )
            cell.delegate = self
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableClass(ShotDetailsLoadMoreCollectionViewCell.self, forIndexPath: indexPath, type: .Cell)
            
            let difference = Int(shot!.commentsCount) - self.comments!.count
            cell.viewData = ShotDetailsLoadMoreCollectionViewCell.ViewData(
                commentsCount: difference > Int(commentsProvider.pagination) ? Int(commentsProvider.pagination).stringValue : difference.stringValue
            )
            cell.delegate = self
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableClass(ShotDetailsHeaderView.self, forIndexPath: indexPath, type: .Header)
            header.viewData = self.header.viewData
            header.delegate = self
            self.header = header
            return header
        } else {
            let footer = collectionView.dequeueReusableClass(ShotDetailsFooterView.self, forIndexPath: indexPath, type: .Footer)
            footer.textField.delegate = self
            footer.delegate = self
            self.footer = footer
            return footer
        }
    }
    
    // MARK: UICollectionViewController Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShotDetailsCollectionViewCell {
            // NGRTodo: check if user can edit this comment (if it is user's comment)
            // what is more, first you should hide editView on all cells
            cell.showEditView()
        }
    }
    
    // MARK: Private
    
    private func setupSubviews() {
        
        setupHeaderView()
        
        // Backgrounds
        view.backgroundColor = UIColor.clearColor()
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        view.insertSubview(blurView, belowSubview: collectionView!)
        blurView.autoPinEdgesToSuperviewEdges()
        collectionView?.backgroundColor = UIColor.clearColor()
        collectionView?.layer.shadowColor = UIColor.grayColor().CGColor
        collectionView?.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        collectionView?.layer.shadowOpacity = 0.3
        
        collectionView?.registerClass(ShotDetailsCollectionViewCell.self, type: .Cell)
        collectionView?.registerClass(ShotDetailsLoadMoreCollectionViewCell.self, type: .Cell)
        collectionView?.registerClass(ShotDetailsHeaderView.self, type: .Header)
        collectionView?.registerClass(ShotDetailsFooterView.self, type: .Footer)
        
        
    }
    
    private func setupHeaderView() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
        if self.userStorageClass.currentUser != nil {
            // NGRFixme: call API for `Check if you like a shot`
            header.viewData = ShotDetailsHeaderView.ViewData(
                description: self.shot!.description?.mutableCopy() as? NSMutableAttributedString,
                title: self.shot!.title!,
                author: self.shot!.user.name ?? self.shot!.user.username,
                client: self.shot!.team?.name,
                shotInfo: dateFormatter.stringFromDate(self.shot!.createdAt),
                shot: self.shot!.image.normalURL.absoluteString,
                avatar: self.shot!.user.avatarString!,
                shotLiked: true, // NGRTodo: provide this info
                shotInBuckets: true // NGRTodo: provide this info
            )
        } else {
            let shotIsLiked = localStorage.likedShots.contains{
                $0.id == self.shot?.identifier
            }
            header.viewData = ShotDetailsHeaderView.ViewData(
                description: shot!.description?.mutableCopy() as? NSMutableAttributedString,
                title: shot!.title!,
                author: shot!.user.name ?? shot!.user.username,
                client: shot!.team?.name,
                shotInfo: dateFormatter.stringFromDate(shot!.createdAt),
                shot: shot!.image.normalURL.absoluteString,
                avatar: shot!.user.avatarString!,
                shotLiked:  shotIsLiked,
                shotInBuckets: true // NGRTodo: provide this info
            )
        }
    }
}

// Mark: Authentication

extension ShotDetailsCollectionViewController {
    func showLoginView() {
        let interactionHandler: (UIViewController -> Void) = { controller in
            self.presentViewController(controller, animated: true, completion: nil)
        }
        let authenticator = Authenticator(interactionHandler: interactionHandler)
        
        firstly {
            authenticator.loginWithService(.Dribbble)
        }.then { Void in
            self.footer.textField.becomeFirstResponder()
        }
    }
}

extension ShotDetailsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // NGRHack: hacky code
    /*
        The problem is that after using `estimatedItemSize` and `preferredLayoutAttributesFittingAttributes` in cell
        it is properly calculated, but not when it first appears.
        After appearing it has `estimatedItemSize` as a size and turns into proper size just after scrolling the collectionView.
        I tried to force showing proper size just from the beginning of appearing and I ended up with this solution.
        I think it's dirty, but the only one working (surprisingly) properly...
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewUsableWidth = collectionView.bounds.width - ((collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left + (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.right)
        var cellHeight: CGFloat
        
        let aLotButEnoughNotToBreakConstraints = CGFloat(5000)
        
        if indexPath.item < comments!.count {
            
            // NGRHack: It's not possible to use `dequeueReusableClass` cause it crashes.
            // This value should be high enough to contain long comment and not to break constraints in cell
            let cell = ShotDetailsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: collectionViewUsableWidth, height: aLotButEnoughNotToBreakConstraints))
            
            let comment = comments![indexPath.item]
            
            cell.viewData = ShotDetailsCollectionViewCell.ViewData(
                avatar: comment.user.avatarString!,
                author: comment.user.name ?? comment.user.username,
                comment: comment.body?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString(),
                time: "time"
            )
            
            cell.layoutIfNeeded()
            
            cellHeight = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height
        } else {
            // NGRHack: It's not possible to use `dequeueReusableClass` cause it crashes.
            // This value should be high enough to contain long comment and not to break constraints in cell
            let cell = ShotDetailsLoadMoreCollectionViewCell(frame: CGRect(x: 0, y: 0, width: collectionViewUsableWidth, height: aLotButEnoughNotToBreakConstraints))
            
            cell.layoutIfNeeded()
            cellHeight = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height
        }

        
        let size = CGSize(width: collectionViewUsableWidth, height: cellHeight)
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
            return header.intrinsicContentSize()
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int) -> CGSize {
            return footer.intrinsicContentSize()
    }
}

extension ShotDetailsCollectionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if !UserStorage.loggedIn {
            showLoginView()
            return false
        }
        
        let cellCount = comments?.count ?? 0
        if cellCount >= changingHeaderStyleCommentsThreshold {
            header.displayCompactVariant()
        }
        footer.displayEditingVariant()
        collectionViewLayout.invalidateLayout()
        collectionView?.layoutIfNeeded()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
       
        if textField.text!.isEmpty == true {
            
            textField.resignFirstResponder()
            
            let cellCount = (comments != nil) ? comments!.count : 0
            if cellCount >= changingHeaderStyleCommentsThreshold {
                header.displayNormalVariant()
            }
            footer.displayNormalVariant()
        } else {
            delegate?.didFinishPresentingDetails(self)
        }
        collectionViewLayout.invalidateLayout()
        collectionView?.layoutIfNeeded()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ShotDetailsCollectionViewController: ShotDetailsHeaderViewDelegate {
    func shotDetailsHeaderView(view: ShotDetailsHeaderView, didTapCloseButton: UIButton) {
        footer.textField.resignFirstResponder()
        delegate?.didFinishPresentingDetails(self)
    }
    
    func shotDetailsHeaderViewDidTapLikeButton(like: Bool, completion: (operationSucceed: Bool) -> Void) {
        
        // NGRTemp: will be refactored
        if like {
            if self.userStorageClass.currentUser != nil {
                let promise = self.shotsRequesterClass.likeShot(self.shot!)
                if let _ = promise.error {
                    completion(operationSucceed: false)
                }
            } else {
                do {
                    try self.localStorage.like(shotID: self.shot!.identifier)
                    
                } catch {
                    completion(operationSucceed: false)
                    return
                }
            }
            completion(operationSucceed: true)
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { action -> Void in
                actionSheet.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let unlikeAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Unlike", comment: ""), style: .Destructive) { action -> Void in
                if self.userStorageClass.currentUser != nil {
                    let promise = self.shotsRequesterClass.unlikeShot(self.shot!)
                    if let _ = promise.error {
                        completion(operationSucceed: false)
                    }
                } else {
                    do {
                        try self.localStorage.unlike(shotID: self.shot!.identifier)
                    } catch {
                        completion(operationSucceed: false)
                        return
                    }
                }
                completion(operationSucceed: true)
            }
            actionSheet.addAction(cancelAction)
            actionSheet.addAction(unlikeAction)
            
            presentViewController(actionSheet, animated: true, completion: nil)
            actionSheet.view.tintColor = UIColor.RGBA(0, 118, 255, 1)
        }
    }
}

extension ShotDetailsCollectionViewController: ShotDetailsCollectionViewCellDelegate {
    
    func shotDetailsCollectionViewCell(view: ShotDetailsCollectionViewCell, didTapCancelButton: UIButton) {
        view.hideEditView()
    }
    
    func shotDetailsCollectionViewCell(view: ShotDetailsCollectionViewCell, didTapDeleteButton: UIButton) {
        // NGRTodo: Implement me!
    }
}

extension ShotDetailsCollectionViewController: ShotDetailsLoadMoreCollectionViewCellDelegate {
    
    func shotDetailsLoadMoreCollectionViewCell(view: ShotDetailsLoadMoreCollectionViewCell, didTapLoadMoreButton: UIButton) {
        firstly {
            self.commentsProvider.nextPage()
        }.then { comments -> Void in
            self.appendCommentsAndUpdateCollectionView(comments! as [Comment], loadMoreCell: view)
        }.error { error in
            // NGRTemp: Need mockups for error message view
            print(error)
        }
    }
    
    private func appendCommentsAndUpdateCollectionView(comments: [Comment], loadMoreCell: ShotDetailsLoadMoreCollectionViewCell) -> Promise<Void> {
        
        let currentCommentCount = self.comments!.count
        var indexPathsToInsert = [NSIndexPath]()
        var indexPathsToReload = [NSIndexPath]()
        var indexPathsToDelete = [NSIndexPath]()
        
        self.comments!.appendContentsOf(comments)
        
        for i in currentCommentCount..<self.comments!.count {
            indexPathsToInsert.append(NSIndexPath(forItem: i, inSection: 0))
        }
        
        if self.comments!.count < Int(shot!.commentsCount) {
            indexPathsToReload.append(collectionView!.indexPathForCell(loadMoreCell)!)
        } else {
            indexPathsToDelete.append(collectionView!.indexPathForCell(loadMoreCell)!)
        }
        
        self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItemsAtIndexPaths(indexPathsToInsert)
                self.collectionView?.reloadItemsAtIndexPaths(indexPathsToReload)
                self.collectionView?.deleteItemsAtIndexPaths(indexPathsToDelete)
            },
            completion:nil
        )
        
        return Promise()
    }
}

extension ShotDetailsCollectionViewController: ShotDetailsFooterViewDelegate {
    func shotDetailsFooterView(view: ShotDetailsFooterView, didTapAddCommentButton: UIButton, forMessage message: String?) {
        footer.textField.resignFirstResponder()
        if message?.isEmpty == false {
            // NGRTodo: begin process of sending comment and reloading collection view
            delegate?.didFinishPresentingDetails(self)
        }
    }
}