# Filtering Operators

- [ignoreElements](#ignoreElements)
- [elementAt](#elementAt)
- [filter](#filter)
- [skip][#skip]
- [skipWhile][#skipWhile]
- [skipUntil](#skipUntil)
- [take](#take)
- [takeWhile](#takeWhile)
- [takeUntil](#takeUntil)
- [takeLast](#takeLast)
- [single](#single)
- [distinctUntilChanged](#distinctUntilChanged)
- [debounce](#debounce)
- [throttle](#throttle)

<br>

### ignoreElements

Observable이 방출하는 Next 이벤트를 필터링하고 Completed이벤트와 Error이벤트만 구독자에게 전달함

주로 작업의 성공과 실패에만 관심있을 때 사용

```swift
public func ignoreElements() -> Completable
```



```swift
let fruits = ["🍈", "🍉", "🍊", "🍋", "🍓"]

Observable.from(fruits)
					.ignoreElements()
          .subscribe { print($0) }
          .disposed(by: diseposeBag)
```

<br>

### elementAt

특정 인덱스에 위치한 요소를 제한적으로 방출하는 연산자

정수 인덱스를 파라미터로 받아 Observable을 리턴

결과적으로 구독자에겐 하나의 이벤트만 전달됨

```swift
public func elementAt() index: Int) -> RxSwift.Observable<Self.Element>
```



```swift
let fruits = ["🍈", "🍉", "🍊", "🍋", "🍓"]

Observable.from(fruits)
					.elementAt(1)
          .subscribe { print($0) }
          .disposed(by: diseposeBag)
/* 출력
next(🍉)
completed
*/
```



<br>

### filter

필터링 연산자

```swift
public func filter(_ predicate: @escaping (Self.Element) throws -> Bool) -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
					.filter { $0.isMultiple(of: 2)}
          .subscribe { print($0) }
          .disposed(by: diseposeBag)
```

<br>

### skip

정수로 지정한 수만큼 스킵하고 이후부터 값을 전달함

```swift
public func skip(_ count: Int) -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
					.skip(3)
          .subscribe { print($0) }		//4부터 방출됨
          .disposed(by: diseposeBag)
```

<br>

### skipWhile

파라미터로 들어간 클로저에서 true를 리턴하는 요소는 무시하고, false인 요소부터 방출 시작

한번 false 리턴 이후에는 조건에 관계없이 모든 요소 방출

```swift
public func skipWhile(_ predicate: @escaping (Self.Element) throws -> Bool) -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
					.skipWhile { !$0.isMultiple(of: 2)}		//홀수일 때 방출되도록
          .subscribe { print($0) }		//2부터 방출됨
          .disposed(by: diseposeBag)
```

`filter()` 와 달리 클로저가 한번 false를 리턴하면 그 이후에는 조건을 판단하지 않음

<br>

### skipUntil

#skipuntil

다른 Observable을 파라미터로 받음. 이 Observable이 Next이벤트를 전달하기 전까지 원본 Observable이 전달하는 이벤트를 무시함. 파라미터로 전달하는 Observable을 트리거라고도 부름

```swift
public func skipUntil<Source: ObservableType>(_ other: Source) -> Observable<Element> {
  return SkipUntil(source: self.asObservable(), other: other:asObservable())
}
```

```swift
let subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()

subject.skipUntil(trigger)
			 .subscribe { print($0) }
			 .disposed(by: disposeBag)

subject.onNext(1)		//trigger가 아직 요소를 방출하지 않았기 때문에 이 이벤트는 전달되지 않음

trigger.onNext(0)		//trigger가 Next 이벤트를 전달한 '이후' 부터 전달하므로

subject.onNext(2)		//여기서부터 전달됨
```



<br>

### take

정수를 파라미터로 받아서 해당 숫자만큼만 요소를 전달함

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
          .take(5)
          .subscribe{ print($0) }		//1,2,3,4,5 만 전달됨
          .disposed(by: disposeBag)
```



<br>

### takeWhile

파라미터로 들어간 클로저가 false를 리턴하면 더이상 요소를 방출하지 않음. true인 동안에만 전달

이후에는 Completed이벤트와 Error이벤트만 전달함

```swift
public func takeWhile(_ predicate: @escaping (Self.Element) throws -> Bool) -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
          .takeWhile{ !$0.isMultiple(of: 2)}
          .subscribe{ print($0) }
          .disposed(by: disposeBag)
```

<br>

### takeUntil

Observable을 파라미터로 받음

파라미터로 전달한 Observable에서 Next이벤트를 전달하기 전까지 원본 Observable에서 Next이벤트를 전달함

```swift
public func takeUntil<Source: ObservableType>(_ other: Source) -> Observable<Element> {
	return TakeUntil(source: self.asObservable(), other: other: asObservable())
}
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

let subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()

subject.takeUntil(trigger)
.subscribe{ print($0) }
.disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)		//아직 trigger가 Next이벤트를 전달하지 않았기 때문에 요소를 방출함

trigger.onNext(0)		//Completed 이벤트가 전달되고, 이 이후로는 이벤트가 방출되지 않음

subject.onNext(3)
```

<br>

### takeLast

버퍼에 정수로 전달한 파라미터만큼 공간을 확보해 맨 나중에 전달된 요소를 저장함. Completed이벤트가 전달될 때까지 구독자로 Next이벤트 전달이 딜레이된다. 반면 Error이벤트가 전달되면 버퍼에 있는 요소를 전달하지 않고 종료됨

```swift
public func takeLast(_ count: Int) -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

let subject = PublishSubject<Int>()
subject.takeLast(2)
        .subscribe{ print($0) }
        .disposed(by: disposeBag)

numbsers.forEach { subject.onNext($0) }
subject.onNext(11)

subject.onCompleted()		//이제서야 버퍼에 저장된 이벤트가 구독자로 방출되고 Completed이벤트가 전달됨
```

<br>

### single

원본 Observable에서 첫번째 요소만 방출하거나 조건과 일치하는 첫번째 요소만 방출함

단 하나의 요소가 방출되어야 정상적으로 종료됨

원본 Observable이 요소를 방출하지 않거나 두개 이상의 요소를 방출한다면 Error 이벤트가 전달됨

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
          .single()				//첫번째 요소 방출하고 시퀀스에 하나 이상의 요소가 있다는 Error 이벤트 방출됨
          .subscribe { print($0) }
          .disposed(by: disposeBag)

Observable.from(numbers)
          .single { $0 == 3}
          .subscribe { print($0) }		//3이 전달되고 Completed이벤트 전달됨
          .disposed(by: disposeBag)
```

<br>

### distinctUntilChanged

동일한 요소가 연속적으로 방출되지 않도록 함
원본 Observable에서 전달되는 요소를 순서대로 비교한 후 바로 이전 요소와 동일하다면 방출하지 않음.

두개의 요소를 비교할 때는 비교연산자로 비교함.

```swift
public func distinctUntilChanged() -> RxSwift.Observable<Self.Element>
```



```swift
let numbers = [1, 1, 3, 2, 2, 5, 6, 1, 6]
Observable.from(numbers)
          .distinctUntilChanged()
          .subscribe { print($0) }	// 1, 3, 2, 5, 6, 1, 6 출력됨
          .disposed(by:disposeBag)
```

<br>

### debounce

짧은시간동안 반복적으로 방출되는 이벤트를 제어

dueTime 파라미터는 연산자가 Next이벤트를 방출할지 조건이 됨

지정된 시간 이내에 Next이벤트를 방출했다면 타이머를 초기화하고 방출하지 않는다면 가장 최근에 방출한 Next이벤트를 구독자에게 전달

타이머를 초기화했다면 다시 지정된 시간동안 대기함

```swift
public func debound(_ dueTime: RxTimeInterval, scheduler: SchedulerType) -> Observable<Element> {
  return Debounce(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
}
```

Next이벤트를 전달한 다음, 지정된 시간까지 다른 이벤트가 전달되지 않는다면 마지막으로 방출된 이벤트를 구독자에게 전달함.

주로 검색기능을 구현할 때 사용. 

사용자가 짧은시간동안 연속해서 문자를 입력할때는 작업이 전달되지 않고 지정된 시간동안 문자를 입력하지 않으면 실제로 검색작업을 실행함. 불필요한 리소스 낭비를 막고 실시간 검색기능을 구현할 수 있음

<br>

### throttle

지정된 주기마다 Next 이벤트를 구독자에게 전달함

짧은시간동안 반복되는 Tap이벤트나 Delegate를 처리할때 사용

```swift
public func throttle(_ dueTime: RxTimeInterval, latest: Bool = true, scheduler: SchedulerType) -> Observable<Element> {
  return Throttle(source: self.asObservable(), dueTime: dueTime, latest: latest, scheduler: scheduler)
}
```

