# Subjects

Subject는 다른 Observable로 이벤트를 받아서 Observer로 전달할 수 있음. **Subject는 Observable과 Observer의 역할을 모두 할 수 있는 proxy/bridge Observable**

*단순 Observable은 unicast방식으로 하나의 Observer만 subscribe 할 수 있고, Subject는 multicast방식으로 여러개의 Observer를 subscribe 할 수 있음*

**Unicast**

각각 subscribed 된 Observer가 Observable에 대해 독립적인 실행을 갖는 것

**Multicast**

하나의 Observable 실행이 여러 subscriber에 공유 됨

<img src = "https://user-images.githubusercontent.com/40784518/92991070-ee59b500-f51b-11ea-816b-c31fc613321e.png" width = 60%/>



### Observable vs Subject

| Observable                                                | Subject                                                      |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| 단지 함수. State 존재 X                                   | state를 가짐. data를 메모리에 저장                           |
| 각각의 Observer에 대해 코드가 실행됨                      | 같은 코드가 실행됨. 모든 Observer에 대해 오직 한번만 실행    |
| 오직 Observable만 생성(data producer)                     | Observable 생성 및 그것을 관찰할 수 있음(data producer & consumer) |
| 하나의 Observer에 대해 간단한 Observable이 필요할 때 사용 | 1. 자주 데이터를 저장하고 수정할 때<br />2. 여러개의 Observer가 데이터를 관찰해야 할 때 <br />3. Observer와 Observable 사이의 프록시 역할이 필요할 때<br />사용함 |



## Subjects



### PublishSubject

Subject로 전달되는 새로운 이벤트를 Observer로 전달

내부에 이벤트가 저장되지 않은 채로 생성됨

```swift
let disposeBag = DisposeBag()

enum MyError: Error {
  case error
}

let subject = PublishSubject<String>()
subject.onNext("Hello")

let observer = subject.subscribe { print($0) }
			.disposed(by: disposeBag)	//아무것도 출력되지 않음

subject.onNext("RxSwift")		// "RxSwift" 출력됨
subject.onCompleted()

let observer2 = subject.subscribe { print($0) }
			.disposed(by: disposeBag)		// subject가 완료된 이후이므로 Completed이벤트만 전달됨

```

생성시에 파라미터 작성하지 않음. 비어있는 상태로 생성됨.

Subject가 생성되는 시점에는 내부에 아무런 이벤트가 저장되어있지 않음

생성 직후에 Observer가 구독을 시작하면 아무런 이벤트도 전달되지 않음

구독 이후에 전달되는 새로운 이벤트만 구독자에게 전달함

Subject가 완료된 이후에(Error 이벤트 || Completed 이벤트) 새로운 이벤트를 전달하면 새로운 구독자에게 전달할 이벤트가 없으므로 바로 (Completed이벤트 || Error이벤트) 만 전달되고 종료됨 

<br>

### BehaviorSubject

생성시점의 subject를 지정함. 가장 마지막에 전달된 최신 이벤트를 저장해 두었다가 새로운 Observer에게 최신 이벤트를 전달함

가장 최신에 저장된 이벤트를 전달하는 subject

생성시점에 만들어진 Next 이벤트를 저장하고 있다가 구독자가 나타나면 전달됨.

BehaviorSubject를 생성하면 내부에 Next 이벤트가 만들어짐. 거기에 생성자로 넣어준 값이 전달됨. 

새로운 구독자가 추가되면, 가장 최근에 저장되어 있는 Next 이벤트가 바로 전달됨. 

```swift
let bs = BehaviorSubject<Int>(value: 0)
b.subscribe { print( "bs1", $0) }
 .disposed(by: disposeBag)				// bs1 0 출력됨

bs.onNext(1)

b.subscribe { print( "bs2", $0) }
 .disposed(by: disposeBag)

/*
bs1 0
bs1 1
bs2 1
*/
```

나중에 구독 시작한 `bs2` 는 가장 최근에 전달된 `1` 부터 전달받을 수 있음. 전에 전달되었던 `0` 은 전달받지 못함. 

앞에 있던것까지 전달받으려면 ReplaySubject 사용 

<br>

### ReplaySubject

하나 이상의 최신 이벤트를 버퍼에 저장. Observer가 구독을 시작하면 버퍼에 있는 모든 이벤트를 전달

두 개 이상의 이벤트를 저장해두고 새로운 구독자에게 전달하고 싶을 때 사용.



```swift
let rs = ReplaySubject<Int>.create(bufferSize: 3)	//#1

(1...10).forEach { rs.onNext($0) }
rs.subscribe { print("observer1", $0) }			// 8,9,10 출력
  .disposed(by: disposeBag)		

rs.onNext(11)		// #2 - 8이 저장된 Next 이벤트가 삭제되고 11이 저장됨

rs.onCompleted()
rs.subscribe { print("observer2", $0) }		//#3 - 버퍼에 저장된 이벤트 전달된 다음, completed 이벤트 전달됨
  .disposed(by: disposeBag)	
```

**#1**

PublishSubject와 BehaviorSubject와 달리 `create` 메소드로 생성함

생성시 버퍼 사이즈를 저장하는데, 이는 몇개의 이벤트를 전달할지 결정

**#2**

새로운 이벤트 전달시, 버퍼에서 가장 오래된 데이터가 삭제됨

버퍼는 메모리에 저장되기 때문에, 항상 메모리 사용량에 신경을 써야 함

**#3**

종료 여부에 관계 없이, 항상 저장된 이벤트를 새로운 구독자에게 전달함

<br>

### AsyncSubject

Publish, Behavior, Replay Subject는 이벤트를 전달받는 즉시 Observer에게 이벤트를 전달, 반면

AsyncSubject는 Completed 이벤트가 전달되는 시점에야 마지막으로 전달된 Next 이벤트를 Observer에게 전달

즉 Completed 이벤트가 전달될 때까지 어떤 이벤트도 Observer에게 전달하지 않음

```swift
let subject = AsyncSubject<Int>()

subject.subscribe { print($0) }
	.disposed(by: disposeBag)

subject.onNext(1)		//전달되지 않음
subject.onNext(2)		//전달되지 않음
subject.onNext(3)		//전달되지 않음

subject.onCompleted()		//3 출력됨
```



Completed 이벤트를 전달하면, 가장 **최근에 전달된 하나의 Next 이벤트를 구독자에게 전달하고 구독이 종료됨**

AsyncSubject로 전달된 Next 이벤트가 없다면, Completed 이벤트만 전달하고 종료됨

Error 이벤트가 전달되는 경우, Next 이벤트가 전달되지 않고 종료됨



<br>

----



### Relay 종류

Subject를 wrapping하고 있음. 다른 소스로부터 이벤트를 받아서 Observer에게 이를 전달하는 역할

주로 종료없이 계속 전달되는 이벤트 시퀀스를 처리할 때 사용됨

Next 이벤트만 전달하고 Error, Completed 이벤트는 전달받지도 하지도 않음. 그래서 종료되지도 않음

구독자가 dispose 하기 전까지 계속 이벤트를 처리함. 그래서 주로 UI 이벤트 처리에 활용됨

RxSwift 프레임워크가 아닌 RxCocoa 프레임워크를 통해 제공됨

<br>



**PublishRelay**

PublishSubject를 wrapping한 것

```swift
let pRelay = PublishRelay<Int>()
pRelay.subscribe { print($0) }
	.disposed(by: disposeBag)

pRelay.accept(1)
```

Relay에 이벤트를 전달할때는 `onNext()` 아닌 `accept(event:)` 사용



<br>

**BehaviorRelay**

BehaviorSubject를 wrapping한 것



```swift
let bRelay = BehaviorRelay(value: 1)

bRelay.accept(2)
bRelay.subscribe { print($0) }	// 가장 최근에 저장된 2가 전달되어 출력됨
	.disposed(by: disposeBag)

bRealy.accept(3)
```

BehaviorRealy에는 value 속성이 있는데, 가장 최근에 Next 이벤트로 전달받은 데이터가 들어있음. 읽기 전용 속성.



---

**Reference**

- https://medium.com/@rkdthd0403/rxswift-subject-99b401e5d2e5

