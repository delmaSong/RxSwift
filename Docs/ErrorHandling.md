# Error Handling

보통 UI가 업데이트 되는 시점은 Next 이벤트가 전달될 때임. Error 이벤트가 전달되면 구독이 종료되고 더 이상 Next 이벤트가 전달되지 않는다. 그래서 UI를 업데이트 하는 코드는 실행되지 않음. 

1. Error 이벤트가 전달되면 새로운 Observable을 리턴한다 
2. Error 발생시 Observable을 다시 구독한다

의 방법으로 에러를 핸들링함

<br>

## Error 이벤트가 전달되면 새로운 Observable을 리턴

Observable이 전달하는 Next이벤트와 Catch 이벤트는 그대로 구독자에게 전달되는 반면, Error이벤트가 전달되면 새로운 Observable을 구독자에게 전달한다

Error가 발생했을 때 사용할 기본값이 있는 경우 `catchErrorJustReturn` 사용

발생한 Error 종류 관계 없이 항상 동일한 값이 리턴된다는 단점이 있음

나머지 경우에는 `catchError` 연산자 사용. 클로저를 통해 에러 처리 코드를 자유롭게 사용할 수 있는 장점이 있음

### catchError Operator

```swift
public func catchError(_ handler: @escaping (Error) throws -> RxSwift.Observable<Self.Element>) -> RxSwift.Observable<Self.Element>
```

Error이벤트를 받아 클로저 파라미터로 전달. 클로저는 새로운 Observable을 리턴. Error가 안난 새로운 Observable로 교체해 리턴함. 혹은 기본값을 전달할 수 있음.

네트워크 요청을 구현할 때 자주 사용. 올바른 응답을 받지 못한 상태에서 로컬 캐시를 사용하거나 기본값을 사용하도록 구현할 수 있음.



```swift
let bag = DisposeBag()
enum MyError: Error {
  case error
}

let subject = PublishSubject<Int>()
let recovery = PublishSubject<Int>()

subject.subscribe { print($0) }
			 .disposed(by:bag)
subject.onError(MyError.error)		// #1 error가 전달되고 바로 구독이 종료되기 때문에 다른 이벤트는 전달되지 않음

subject.catchError{ _ in recovery }
			 .subscribe{ print($0) }
			 .disposed(by:bag)
subject.onError(MyError.error)		// #2 Observable을 새로운 서브젝트(recovery)로 변경해 리턴해서, Error가 전달되지 않음

subject.onNext(11)		// 전달되지 않음
recovery.onNext(22)		// 전달됨
```



<br>

### catchErrorJustReturn Operator

```swift
public func catchErrorJustReturn(_ element: Self.Element) -> RxSwift.Observable<Self.Element>
```

Error가 발생하면 파라미터로 전달한 기본 값을 구독자에게 전달함. 파라미터의 타입은 Observable이 전달하는 타입과 같음

<br>

```swift
let subject = PublishSubject<Int>()

subject.catchErrorJustReturn(-1)
			 .subscribe { print($0) }
			 .disposed(by:bag)
subject.onError(MyError.error)		//Error 이벤트가 전달되므로, 파라미터로 전달한 -1이 출력되고 종료됨
```



<br>

## Error 발생 시 Observable을 다시 구독함

작업을 처음부터 다시 시작하고 싶은 경우 사용

에러가 발생하지 않을때까지 무한정 재시도하거나 재시도 횟수를 제한할 수 있음

### retry Operator

```swift
//Observable이 완료될때까지 계속해서 재시도. 심한경우 무한루프 빠져 크래시날 수 있으므로 되도록 사용 안함
public func retry() -> RxSwift.Observable<Self.Element>

// 재시도 횟수를 파라미터로 전달. 재시도 횟수 +1만큼 해야 원하는 횟수만큼 재시도 함
public func retry(_ maxAttemptCount: Int) -> RxSwift.Observable<Self.Element>
```

Error 발생 시 구독을 해지하고 새로운 구독 시작.

새로운 구독이 시작되므로 Observable Sequence는 처음부터 다시 시작됨

Observable에서 에러가 발생하지 않으면 정상적으로 종료되고, 에러가 발생하면 또다시 새로운 구독을 시작함

<br>

```swift
let source = Observable<Int>.create { observer in
                                     let currentAttempts = attempts
                                     print("#\(currentAttempts) START")

                                     if attempts < 3 {
                                       observer.onError(MyError.error)
                                       attempts +=1
                                     }

                                     observer.onNext(1)
                                     observer.onNext(2)

                                     return Disposables.create {
                                       print("#\(currentAttempts) END")
                                     }
                                   }
source.retry()
			.subscirbe { print($0) }
			.disposed(by: bag)
/* 출력
#1 START
#1 END
#2 START
#2 END
#3 START
next(1)
next(2)
completed
#3 END
*/
```

`retry()` 는 에러가 발생한 즉시 재시도하므로 재시도 시점을 제어하기는 불가능함. 네트워크 요청에서 에러가 발생했다면 정상 응답을 받거나 최대횟수에 도달할때까지 재시도함. 

만약 사용자가 재시도버튼을 탭하는 시점에만 재시도를 하고싶다면? `retryWhen()` 사용 



<br>

### retryWhen Operator

```swift
public func retryWhen<TriggerObservable: ObservableType, Error: Swift.Error>(_ notificationHandler: @escaping (Observable<Error>) -> TriggerObservable) -> Observable<Element>
```

원하는 시점에 재시도 할 수 있는 연산자

TriggerObservable이 파라미터로 함수를 전달받게 만들고, 에러가 발생한 시점에 해야 할 동작을 `retryWhen()` 을 통해 전달해 기존 Observable이 새로운 구독을 시작하게 한다

<br>

```swift
let source = Observable<Int>.create { observer in
                                     let currentAttempts = attempts
                                     print("#\(currentAttempts) START")

                                     if attempts < 3 {
                                       observer.onError(MyError.error)
                                       attempts +=1
                                     }

                                     observer.onNext(1)
                                     observer.onNext(2)

                                     return Disposables.create {
                                       print("#\(currentAttempts) END")
                                     }
                                   }

let trigger = PublishSubject<Void>()
source.retryWhen { _ in trigger }		//바로 연산하지 않고 trigger Observable이 Next이벤트를 전달할때까지 대기함
			.subscirbe { print($0) }
			.disposed(by: bag)

trigger.onNext(())		//source Observable에서 새로운 구독을 시작함 
```





