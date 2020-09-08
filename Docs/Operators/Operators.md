## Create Operators

<br>

## just, of, them

하나의 항목을 방출하는 Observable 생성

<br>

### just

parameter로 받은 요소를 그대로 방출함

```swift
Observable.just("😆")
					.subscribe { event in print(event) }		// 😆 출력됨
					.disposed(by: disposeBag)

Observable.just([1, 2, 3])
					.subscribe { event in print(event) }		// [1, 2, 3] 출력됨
					.disposed(by: disposeBag)
```

<br>

### of

가변 파라미터를 받아, 방출할 요소를 원하는만큼 전달할 수 있음

```swift
Observable.of([1, 2], [3, 4], [5, 6])
					.subscribe{ event in print{event} }
					.disposed(by: disposeBag)

/* 출력
[1, 2]
[3, 4]
[5, 6]
*/
```

<br>

### from

배열을 파라미터로 받아, 배열의 포함된 요소를 하나씩 리턴함

```swift
let fruits = ["🍑", "🍐", "🍋"]
Observable.from(fruits)
					.subscribe{ event in print{event} }
					.disposed(by: disposeBag)
/* 출력
🍑
🍐
🍋
*/
```

<br>

<br>

## range, them

정수를 지정된 수만큼 방출하는 Observable

<br>

### range

시작값에서 1씩 증가하는 시퀀스를 생성하는 메소드

증가하는 크기를 바꾸거나, 감소하는 시퀀스는 불가

파라미터 형식이 정수로 제한됨

```swift
Observable.range(start: 1, count: 5)
					.subscribe { print($0) }
					.disposed(by: disposeBag)

/*
1
2
3
4
5
*/
```

<br>

### generate

초기값과, 조건, 클로저를 파라미터로 받음 

파라미터 형식이 정수로 제한되지 않음

```swift
//0부터 1씩 증가하며 10이하인 값들만 출력
Observable.generate(initialState: 0, condition: { $0 <= 10}, iterate: {$0 + 2})
					.subscribe { print($0) }
					.disposed(by: disposeBag)

let red = "🍎"
let green = "🍏"

Obervable.generate(initialState: red,
                   condition: { $0.count < 5 }, 
                   iterate: { $0.count.isMultiple(of:2) ? $0 + red : $0 + green})
					.subscribe { print($0) }
					.disposed(by: disposeBag)
/*	출력
🍎
🍎🍏🍎
🍎🍏🍎🍏
🍎🍏🍎🍏🍎
*/
```

조건이 false인 경우 Completed 이벤트를 전달하고 종료

<br>

### repeatElement

동일한 요소를 반복적으로 방출

```swift
let element = "🍏"
Observable.repeatElement(element)
					.subscribe { print($0) }
					.disposed(by: disposeBag)
```

<br>

## deferred

특정 조건에 따라 Observable을 생산할 수 있음

Observable을 리턴하는 클로저를 파라미터로 받음

```swift
let disposeBag = DisposeBag()
let animals = ["🐶", "🐱", "🐛", "🐝", "🦕"]
let fruits = ["🍐", "🍊", "🍒", "🥑", "🍋"]
var flag = true

let factory: Observable<String> = Observable.deferred {
 flag.toggle()
  
  if flag {		// 조건에 따라 Observable을 리턴함
    return Observable.from(animals)
  } else {
    return Observable.from(fruits)
  }
}

factory.subscribe { print($0) }
			 .disposed(by: disposeBag)
```

<br>

## create

Observable이 동작하는 방식을 직접 구현할 때 사용

```swift
Observable<String>.create { (observer) -> Disposable in
  guard let url = URL(string: "https://www.apple.com") else {
    observer.onError(MyError.error)
    return Disposables.create()
  }
  guard let html = try? String(contentsOf: url, encoding: .utf8) else {
    observer.onError(MyError.error)
    return Disposables.create()
  }
  observer.onNext(html)
  observer.onCompleted()
                           
	return Disposables.create()
}
.subscribe { print($0) }
.disposed(by: disposeBag)
```

<br>

## empty, error

두 연산자 모두 Next 이벤트를 전달하지 않음

다시 말해 어떠한 요소도 방출하지 않는다.



### empty

Completed 이벤트를 전달하는 Observable을 생성

Observer가 아무런 이유없이 종료할 때 자주 사용

```swift
Observable<Void>.empty()
.subscribe { print($0) }
.disposed(by: disposeBag)
```

<br>

### error

Error 이벤트를 전달하고 종료하는 Observable을 생성

주로 에러를 처리할 때 이 연산자를 사용

```swift
Observable<Void>.error(MyError.error)
.subscribe { print($0) }
.disposed(by: disposeBag)
```

