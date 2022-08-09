//
//  PostViewController.swift
//  SamplePost
//
//  Created by mtanaka on 2022/08/08.
//

import UIKit
import RxSwift
import RxCocoa

final class PostViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var showAlbumButton: UIButton!
    @IBOutlet private weak var postButton: UIButton!
    
    private var postViewModel:PostViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
            super.viewDidLoad()
        self.postViewModel = PostViewModel(input: (postButtonTap: postButton.rx.tap.asSignal(), text: textView.rx.text.orEmpty.asDriver()),postAPI: PostDefaultAPI())
        
        //albumButtonをタップ
        showAlbumButton.rx.tap.subscribe { [weak self] _ in
                self?.showAlbum()
            }
            .disposed(by: disposeBag)
        
        //投稿文または写真があれば投稿できるようにする
        postViewModel.validPostDriver
                .drive { [weak self] bool in
                    self?.postButton.isEnabled = bool
                    self?.postButton.backgroundColor = bool ? .red : .systemGray4
                }
                .disposed(by: disposeBag)
        
        //投稿完了通知
            postViewModel.postedDriver
                .drive { [weak self] bool in
                    switch bool {
                    case true:
                        self?.dismiss(animated: true, completion: nil)
                    case false:
                        print("false!!!!!!!!!!!!!")
                    }
                    
                }
                .disposed(by: disposeBag)
        }


        private func showAlbum() {
//        let pickerController = DKImagePickerController()
//            pickerController.maxSelectableCount = 2
//            pickerController.sourceType = .photo
//            pickerController.assetType = .allPhotos
//            pickerController.allowSelectAll = true
//            pickerController.showsCancelButton = true
//            pickerController.didSelectAssets = {(assets: [DKAsset]) in
//                for asset in assets {
//                    asset.fetchFullScreenImage { image, info in
//                        if var item = try? self.postViewModel.photoArrayOutPut.value() {
//                            item.append(image!)
//                            self.postViewModel.photoArrayInPut.onNext(item)
//                        }
//                    }
//                }
//            }
//            pickerController.modalPresentationStyle = .fullScreen
//            pickerController.UIDelegate = CustomUIDelegate()
//            self.present(pickerController, animated: true, completion: nil)
        }
        
        
    }
