//
//  TwoWayBinding.swift
//  RxSwiftAddons
//
//  Created by Krunoslav Zaher and Andres on 11/7/16.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

infix operator <-> {
}

private func nonMarkedText(textInput: RxTextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument
    
    guard let rangeAll = textInput.textRangeFromPosition(start, toPosition: end),
        text = textInput.textInRange(rangeAll) else {
            return nil
    }
    
    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }
    
    guard let startRange = textInput.textRangeFromPosition(start, toPosition: markedTextRange.start), endRange = textInput.textRangeFromPosition(markedTextRange.end, toPosition: end) else {
            return text
    }
    
    return (textInput.textInRange(startRange) ?? "") + (textInput.textInRange(endRange) ?? "")
}

extension RxTextInput {
    func twoWayDrive<S:protocol<SubjectType, ObserverType> where S.E == String>(subject:S) -> Disposable {
        return twoWayBinding(subject,
                             bindToUI: { $0.asDriver(onErrorDriveWith: Driver.never()).drive($1.rx_text) },
                             setValueFromUI: { $0.onNext($1) })
    }
    
    func twoWayDrive(variable:Variable<String>) -> Disposable {
        return twoWayBinding(variable,
                             bindToUI: { $0.asDriver().drive($1.rx_text) },
                             setValueFromUI: { $0.value = $1 })
    }
    
    func twoWayBindTo<S:protocol<SubjectType, ObserverType> where S.E == String>(subject:S) -> Disposable {
        return twoWayBinding(subject,
                             bindToUI: { $0.asObservable().bindTo($1.rx_text) },
                             setValueFromUI: { $0.onNext($1) })
    }
    
    func twoWayBindTo(variable:Variable<String>) -> Disposable {
        return twoWayBinding(variable,
                             bindToUI: { $0.asObservable().bindTo($1.rx_text) },
                             setValueFromUI: { $0.value = $1 })
    }
    
    public func twoWayBinding<T>(object:T, bindToUI:(T, Self)->(Disposable), setValueFromUI:(T, String)->()) -> Disposable {
        let bindToUIDisposable = bindToUI(object, self)
        let bindToVariable = self.rx_text
            .subscribe(onNext: { [weak self] n in
                guard let textInput = self else { return }
                let nonMarkedTextValue = nonMarkedText(textInput)
                
                /*
                 In some cases `textInput.textRangeFromPosition(start, toPosition: end)` will return nil even though the underlying
                 value is not nil. This appears to be an Apple bug. If it's not, and we are doing something wrong, please let us know.
                 The can be reproed easily if replace bottom code with
                 
                 if nonMarkedTextValue != variable.value {
                 variable.value = nonMarkedTextValue ?? ""
                 }
                 and you hit "Done" button on keyboard.
                 */
                
                if let nonMarkedTextValue = nonMarkedTextValue {
                    setValueFromUI(object, nonMarkedTextValue)
                }
                }, onCompleted:  {
                    bindToUIDisposable.dispose()
            })
        
        return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
    }
}

public extension ObservableType where Self:protocol<ObserverType> {
    func twoWayDrive<S:protocol<SubjectType, ObserverType> where S.E == E>(subject:S) -> Disposable {
        return twoWayBinding(subject,
                             bindToUI: { $0.asDriver(onErrorDriveWith: Driver.never()).drive($1) },
                             setValueFromUI: { $0.onNext($1) })
    }
    
    func twoWayDrive(variable:Variable<E>) -> Disposable {
        return twoWayBinding(variable,
                             bindToUI: { $0.asDriver().drive($1) },
                             setValueFromUI: { $0.value = $1 })
    }
    
    func twoWayBindTo<S:protocol<SubjectType, ObserverType> where S.E == E>(subject:S) -> Disposable {
        return twoWayBinding(subject,
                             bindToUI: { $0.asObservable().bindTo($1) },
                             setValueFromUI: { $0.onNext($1) })
    }
    
    func twoWayBindTo(variable:Variable<E>) -> Disposable {
        return twoWayBinding(variable,
                             bindToUI: { $0.asObservable().bindTo($1) },
                             setValueFromUI: { $0.value = $1 })
    }
    
    func twoWayBinding<T>(object:T, bindToUI:(T, Self)->(Disposable), setValueFromUI:(T, E)->()) -> Disposable {
        if E.self == String.self {
            #if DEBUG
                fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx_text` property directly to variable.\n" +
                    "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
                    "REMEDY: Just use `textField <-> variable` instead of `textField.rx_text <-> variable`.\n" +
                    "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
                )
            #endif
        }
        
        let bindToUIDisposable = bindToUI(object, self)
        let bindToVariable = self.subscribe(
            onNext: {
                setValueFromUI(object, $0)
            },onCompleted:  {
                bindToUIDisposable.dispose()
        })
        
        return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
    }
}