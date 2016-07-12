//
//  TwoWayBinding.swift
//  RxSwiftAddons
//
//  Created by Krunoslav Zaher and Andrés Cecilia on 11/7/16.
//  Copyright © 2016 Andrés Cecilia. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public extension SubjectType where Self:protocol<ObserverType> {
    /**
     Creates a twoWayConnection between the left and right operand. IMPORTANT: for connections with InputText elements is preferable to use the subject.twoWayWhatever(InputText) methods. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
     
     - parameter property: the property to drive
     
     - returns: Subscription object used to unsubscribe from the observable sequence
     */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func twoWayDrive<P:protocol<ObservableType, ObserverType> where P.E == E>(property:P) -> Disposable {
        return twoWayBinding(self, property: property,
                             bindToUI: { $0.asDriver(onErrorDriveWith: Driver.never()).drive($1) },
                             setValueFromUI: { $0.onNext($1) })
    }
    
    /**
     Creates a twoWayConnection between the left and right operand. IMPORTANT: for connections with InputText elements is preferable to use the subject.twoWayWhatever(InputText) methods. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
     
     - parameter property: the property to bind
     
     - returns: Subscription object used to unsubscribe from the observable sequence
     */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func twoWayBindTo<P:protocol<ObservableType, ObserverType> where P.E == E>(property:P) -> Disposable {
        return twoWayBinding(self, property: property,
                             bindToUI: { $0.asObservable().bindTo($1) },
                             setValueFromUI: { $0.onNext($1) })
    }
}

public extension Variable {
    /**
     Creates a twoWayConnection between the left and right operand. IMPORTANT: for connections with InputText elements is preferable to use the InputText.twoWayWhatever methods. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
     
     - parameter property: the property to drive
     
     - returns: Subscription object used to unsubscribe from the observable sequence
     */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func twoWayDrive<P:protocol<ObservableType, ObserverType> where P.E == E>(property:P) -> Disposable {
        return twoWayBinding(self, property: property,
                             bindToUI: { $0.asDriver().drive($1) },
                             setValueFromUI: { $0.value = $1 })
    }
    
    /**
     Creates a twoWayConnection between the left and right operand. IMPORTANT: for connections with InputText elements is preferable to use the InputText.twoWayWhatever methods. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
     
     - parameter property: the property to bind
     
     - returns: Subscription object used to unsubscribe from the observable sequence
     */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func twoWayBindTo<P:protocol<ObservableType, ObserverType> where P.E == E>(property:P) -> Disposable {
        return twoWayBinding(self, property: property,
                             bindToUI: { $0.asObservable().bindTo($1) },
                             setValueFromUI: { $0.value = $1 })
    }
}

/**
 Creates a twoWayConnection between the left and right operand. IMPORTANT: for connections with InputText elements is preferable to use the specific methods created for it. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
 
 - parameter subject:        the subject to bind
 - parameter property:       the property to bind
 - parameter bindToUI:       the binding from subject to property
 - parameter setValueFromUI: the binding from property to subject
 
 - returns: Subscription object used to unsubscribe from the observable sequence
 */
@warn_unused_result(message="http://git.io/rxs.ud")
public func twoWayBinding<S, P:protocol<ObservableType, ObserverType>>(subject: S, property:P, bindToUI:(S, P)->(Disposable), setValueFromUI:(S, P.E)->()) -> Disposable {
    if P.E.self == String.self {
        #if DEBUG
            fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx_text` property directly to variable.\n" +
                "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
                "REMEDY: Just use `textField.twoWayBindTo or textField.twoWayDrive` (if it is available in your platform) instead of `variable.twoWayBindTo or variable.twoWayDrive`.\n" +
                "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
        #endif
    }
    
    let bindToUIDisposable = bindToUI(subject, property)
    let bindToVariable = property.subscribe(
        onNext: {
            setValueFromUI(subject, $0)
        },onCompleted:  {
            bindToUIDisposable.dispose()
    })
    
    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

#if os(iOS) || os(tvOS)
    public extension SubjectType where Self:protocol<ObserverType>, E == String {
        /**
         Creates a twoWayConnection between the left and right operand specifically implemented for inputText. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
         
         - parameter property: the property to drive
         
         - returns: Subscription object used to unsubscribe from the observable sequence
         */
        @warn_unused_result(message="http://git.io/rxs.ud")
        public func twoWayDrive(property:RxTextInput) -> Disposable {
            return twoWayBinding(self, property: property,
                                 bindToUI: { $0.asDriver(onErrorDriveWith: Driver.never()).drive($1.rx_text) },
                                 setValueFromUI: { $0.onNext($1) })
        }
        
        /**
         Creates a twoWayConnection between the left and right operand specifically implemented for inputText. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
         
         - parameter property: the property to bind
         
         - returns: Subscription object used to unsubscribe from the observable sequence
         */
        @warn_unused_result(message="http://git.io/rxs.ud")
        public func twoWayBindTo(property:RxTextInput) -> Disposable {
            return twoWayBinding(self, property: property,
                                 bindToUI: { $0.asObservable().bindTo($1.rx_text) },
                                 setValueFromUI: { $0.onNext($1) })
        }
    }
    
    /**
     FIXME: We can not extend Variable because compiler complains: "Same type requirement makes generic parameter 'Element' non-generic" when constraining the Variable type to String. Solution: extend the RxTextInput
     - The discoverability is really bad
     */
    public extension RxTextInput {
        /**
         Creates a twoWayConnection between the left and right operand specifically implemented for inputText. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
         
         - parameter variable: the variable to drive
         
         - returns: Subscription object used to unsubscribe from the observable sequence
         */
        @warn_unused_result(message="http://git.io/rxs.ud")
        public func twoWayDrive(variable:Variable<String>) -> Disposable {
            return twoWayBinding(variable, property: self,
                                 bindToUI: { $0.asDriver().drive($1.rx_text) },
                                 setValueFromUI: { $0.value = $1 })
        }
        
        /**
         Creates a twoWayConnection between the left and right operand specifically implemented for inputText. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
         
         - parameter variable: the variable to bind
         
         - returns: Subscription object used to unsubscribe from the observable sequence
         */
        @warn_unused_result(message="http://git.io/rxs.ud")
        public func twoWayBindTo(variable:Variable<String>) -> Disposable {
            return twoWayBinding(variable, property: self,
                                 bindToUI: { $0.asObservable().bindTo($1.rx_text) },
                                 setValueFromUI: { $0.value = $1 })
        }
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
    
    /**
     Creates a twoWayConnection between the left and right operand specifically designed for inputText. Find out more here: https://github.com/ReactiveX/RxSwift/issues/649
     
     - parameter subject:        the subject to bind
     - parameter property:       the property to bind
     - parameter bindToUI:       the binding from subject to property
     - parameter setValueFromUI: the binding from property to subject
     
     - returns: Subscription object used to unsubscribe from the observable sequence
     */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func twoWayBinding<S>(subject: S, property:RxTextInput, bindToUI:(S, RxTextInput)->(Disposable), setValueFromUI:(S, String)->()) -> Disposable {
        let bindToUIDisposable = bindToUI(subject, property)
        let bindToVariable = property.rx_text
            .subscribe(onNext: { [weak property] n in
                guard let textInput = property else { return }
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
                    setValueFromUI(subject, nonMarkedTextValue)
                }
                }, onCompleted:  {
                    bindToUIDisposable.dispose()
            })
        
        return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
    }
#endif