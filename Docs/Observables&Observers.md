## Observables & Observers

### Observables

Observable == observable Sequence == Sequence



**Observable**

- Observable은 이벤트를 전달함
- Observable은 이벤트가 어떤 순서로 전달될지 정의함
- Observable은 세가지 이벤트(Next, Error, Completed)를 전달
  - Next : Observable에서 발생한 새로운 이벤트를 전달함. Emission이라고 표현. Next는 값을 포함할 수 있음
  - Error: 에러 발생 시 전달되는 이벤트. Notification이라고 표현
  - Completed: 정상 종료시 전달되는 이벤트. Notification이라고 표현
- Error와 Completed는 Observable의 LifeCycle에서 가장 마지막에 전달되므로 이후에는 이벤트가 전달되지 않음
- Error와 Completed가 전달된 후에는 Observable이 종료됨
- Observer가 Observable을 구독해야지 값이 전달됨
- 여러 이벤트를 동시에 전달하지 않음



**Observer**

- Observer는 Observable을 감시하다가 전달되는 이벤트를 처리함

- Observable을 감시하는 것을 구독(Subscribe)한다고 표현한다. 그래서 Observer를 Subscriber라고도 표현함
- Observer가 Observable을 구독하는 시점에 Next 이벤트를 통해 값이 전달되고 이어서 Completed 이벤트가 전달됨
- Observer가 Observable을 구독하는 방법은 Observable에서 subscribe메소드를 호출하면 됨
- Observer가 구독을 시작한 시점에 이벤트가 전달됨



<br>

------



### Observable 생성하기

1. `create` 연산자를 이용해 직접 생성

```swift
Observable<Int>.create { (observer) -> Disposable in
                        observer.on(.next(0))				//subscriber로 0이 담겨있는 next 이벤트가 전달됨
                        observer.onNext(1)					//위랑 같은 동작
                        observer.onCompleted() 			//completed 이벤트가 전달되고 observable이 종료된다

                        return Disposables.create()	//메모리 정리에 필요한 객체인 Disposable을 리턴해야 함
                       }
```



2. `create` 가 아닌 미리 정의된 다른 연산자를 활용하여 생성

   ```swift
   Observable.from([0, 1])
   ```



<br>



### Observable 구독하기

Observer가 Observable을 구독하는 방법은 Observable에서 subscribe메소드를 호출하면 됨.

Subscribe 메소드는 Observable과 Obserer를 연결함. 두 요소를 연결해야 이벤트가 전달됨. 

```swift
let o1 = Observable.from([0, 1])

o1.subscribe {										// 이 메소드가 subscriber
  print($0)
  if let element = $0.element {
    print(element)								// 전달되는 이벤트 안의 요소만 빼내고 싶을 때 element 속성을 이용함. 
  }
}

o1.subscribe(onNext: { element in // 클로저 파라미터로 Next 이벤트에 전달된 요소가 바로 전달되므로 바로 사용 가능
             print(element)		
})																//개별 이벤트를 별도의 클로저에서 사용하고 싶을 때 이 메소드 사용
```



Observable은 이벤트가 전달되는 순서를 정의하는데, 실제로 이벤트가 전달되는 시점은 Observer가 구독을 시작한 시점. 

Observer는 동시에 2개 이상의 이벤트를 처리하지 않음. 

Observable은 Observer가 하나의 이벤트를 처리한 후에 이어지는 이벤트를 전달한다. 여러 이벤트를 동시에 전달하지 않는다. 