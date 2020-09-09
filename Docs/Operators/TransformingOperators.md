# Transforming Operators

- [toArray](#toArray)
- [map](#map)
- [flatMap](#flatMap)
- [flatMapFirst](#flatMapFirst)
- [flatMapLatest](#flatMapLatest)
- [scan](#scan)
- [window](#window)
- [groupBy](#groupBy)

<br>

### toArray

Observable이 방출하는 모든 요소를 싱글타입의 Observable로 만들어 방출

>  Single? 하나의 요소를 방출하거나 Error 이벤트를 전달하는 Observable

```swift
public void toArray() -> Single<[Self.Element>]
```



```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
let subject = PublishSubject<Int>()

subject.toArray()
        .subscribe { print($0) }
        .disposed(by: disposeBag)

subject.onNext(1)		// 전달되지 않음
subject.onNext(2)		// 전달되지 않음
subject.onCompleted()		//[1, 2]가 전달됨
```

방출하는 모든 요소를 배열로 만드는데, 방출이 종료된 시점에야 모든 요소가 전달됐음을 알기때문에 toArray()를 이용하면 Observable이 종료되기 전까지 요소가 전달되지 않음

<br>

### map

Observable이 배출하는 항목을 대상으로 함수를 실행하고 실행결과를 방출하는 Observable을 리턴

```swift
let skills = ["Swift", "SwiftUI", "RxSwift"]

Observable.from(skills)
					.map { "Hello \($0)" }
          .subscribe { print($0) }
          .disposed(by: disposeBag)
```

파라미터와 동일한 형식을 리턴하지 않아도 됨



<br>

### flatMap

이벤트를 또다른 Observable로 바꿈

원본 Observable이 요소를 방출하면 `flatMap()` 이 변환을 실행함. 변환 함수는 방출된 항목을 Observable로 변환. 

방출된 항목이 바뀌면, flatMap 연산자가 변환한 Observable이 새로운 항목을 방출함

원본 Observable이 방출하는 항목을 지속적으로 감시하고 최신값을 확인할 수 있음

플랫맵은 모든 Observable이 방출하는 항목을 모아서 최종적으로 하나의 Observable을 리턴함

```swift
let a = BehaviorSubject(value: 1)
let b = BehaviorSubject(value: 2)

let subject = PublishSubject<BehaviorSubject<Int>>()
subject.flatMap { $0.asObservable() }
        .subscribe { print($0) }
        .disposed(by: disposeBag)

subject.onNext(a)	//전달됨
subject.onNext(b)		//전달됨

a.onNext(11)		//구독자로 새로운 항목이 전달된다
```



<br>

### flatMapFirst

원본 Observable이 방출하는 항목을 Observable로 변환

변환된 Observable이 방출하는 모든 항목을 하나로 모아 단일 Observable을 리턴함

연산자가 리턴하는 Observable에는 처음에 변환된 Observable이 방출하는 항목만 있음

```swift
let a = BehaviorSubject(value: 1)
let b = BehaviorSubject(value: 2)

let subject = PublishSubject<BehaviorSubject<Int>>()
subject.flatMapFirst { $0.asObservable() }
        .subscribe { print($0) }
        .disposed(by: disposeBag)

subject.onNext(a)
subject.onNext(b)

a.onNext(11)
b.onNext(22)
a.onNext(111)
b.onNext(222)

/* 출력
next(1)
next(11)
next(111)
*/
```

처음에 전달된 Observable이 방출되는 항목만 전달함

<br>

### flatMapLatest

모든 Observable이 방출하는 항목을 하나로 병합하지 않음

대신 가장 최근의 항목을 방출하는 Observable을 제외한 나머지는 모두 무시

```swift
let a = BehaviorSubject(value: 1)
let b = BehaviorSubject(value: 2)

let subject = PublishSubject<BehaviorSubject<Int>>()
subject.flatMapLatest { $0.asObservable() }
        .subscribe { print($0) }
        .disposed(by: disposeBag)

subject.onNext(a)	//전달됨
a.onNext(11)		//전달됨

subject.onNext(b)		//이때부터 a가 방출하는 항목은 무시하고 b가 방출하는 항목만 전달함 
b.onNext(22)		//전달됨

a.onNext(11)		//전달되지 않음
```

<br>

### scan

기본값으로 연산 시작

원본 Observable이 방출하는 항목을 대상으로 변환을 시작한다음 결과를 방출하는 하나의 Observable을 리턴함

그래서 원본이 방출하는 항목 수와 구독자가 방출하는 항목의 수가 동일함

```swift
//seed: 기본값
public func scan<A>(_ seed: A, accumulator: @escaping (A, Self.Element) throws -> A) -> RxSwift.Observable<A>
```



```swift
Observable.range(start: 1, count: 10)
          .scan(0, accumulator: +)
          .subscribe{ print($0) }
          .disposed(by: disposeBag)
```

<br>

### buffer

특정 주기동안 Observable이 방출하는 항목을 수집하고 하나의 배열로 리턴-> Controlled Buffer 라고 함

시간이 경과하지 않은 경우에도 항목을 배출할 수 있음

```swift
//timeSpan - 주기(도달하지 않더라도 count에 도달하면 방출함), count - 수집할 최대 항목 수(도달하지 않더라도 시간이 되면 방출함)
public func buffer(timeSpan: RxTimeInterval, count: Int, scheduler: SchedulerType) -> RxSwift.Observable<[Self.Element]>
```

RxTimeInterval은 더이상 사용하지 않는 형식이라 DispatchTimeInterval같은 타입을 사용함

```swift
Observable<Int>.interval(.second(1), scheduler: MainScheduler.instance)
                .buffer(timeSpan: .seconds(2), count: 3, scheduler: MainScheduler.instance)
                .take(5)
                .subscribe{ print($0) }
                .disposed(by: disposeBag)

/* 출력
[0]
[1, 2, 3]
[4, 5]
[6, 7]
[8, 9]
completed
*/
```



<br>

### window



<br>

### groupBy