//
//  PostViewModel.swift
//  SamplePost
//
//  Created by mtanaka on 2022/08/08.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class PostViewModel {
    
    private let disposeBag = DisposeBag()
    
    var photoArrayOutput = BehaviorSubject<[UIImage]>.init(value: [])
    var photoArrayInput: AnyObserver<[UIImage]> {
        // photoArrayOutPut.asObserver()とすることで、値が送られてきたらphotoArrayOutPutに値が代入される
        photoArrayOutput.asObserver()
    }
    
    var validPostSubject = BehaviorSubject<Bool>.init(value: false)
    var postCompletedSubject = BehaviorSubject<Bool>.init(value: true)
    
    var validPostDriver: Driver<Bool> = Driver.never()
    var postedDriver: Driver<Bool> = Driver.never()
    
    init(input: (postButtonTap: Single<()>, text: Driver<String>), postAPI: PostAPI) {
        // 投稿ボタンのバリデーション
        validPostDriver = validPostSubject
            .asDriver(onErrorDriveWith: Driver.empty()) //エラーを無視
        
        let validPostText = input.text
            .asObservable()
            .map { text -> Bool in
                return text != ""
            }
        
        let validPhotoArray = photoArrayOutput
            .asObservable()
            .map { photos -> Bool in
                return photos != []
            }
        // 二つのObservableを合成してtext != "" || photos != [] であればtrueを返す
        Observable.combineLatest(validPostText, validPhotoArray) { $0 || $1 }
            .subscribe { bool in
                // validPostSubjectにbool値を流す
                self.validPostSubject.onNext(bool)
            }
            .disposed(by: disposeBag)
        // ボタンタップを検知してFirestoreに保存する
        // ここでもDriverとSubjectを紐付けしてあげて、エラーの場合はfalseを返すようにします。
        postedDriver = postCompletedSubject.asDriver(onErrorJustReturn: false)
        // photoArrayOutPutを観察
        let imageArrayObservable = photoArrayOutput
            .asObservable()
        // textを観察
        let textObservable = input.text.asObservable()
        // 二つのObservableを合成
        let combineObservable = Observable.combineLatest(imageArrayObservable, textObservable)
        
        input.postButtonTap
            .asObservable()
            .withLatestFrom(combineObservable)
            .flatMapLatest { (imageArray, text) -> Single<Bool> in
                return postAPI.post(text: text, imageArray: imageArray)
            }
            .subscribe { [weak self] bool in
                switch bool {
                case .next(let bool):
                    self?.postCompletedSubject.onNext(bool)
                case .error(let error):
                    print("エラーですよー", error)
                    self?.postCompletedSubject.onNext(false)
                case .completed:
                    print("completed")
                }
            }
            .disposed(by: disposeBag)
    }
}
