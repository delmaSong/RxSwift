

## Disposables

리소스 정리에 사용되는 객체



```swift
Observable.from([1, 2, 3])
	.subscribe(onNext: { element in
	    print("Next", element)
	  }, onError: { error in
	    print("Error", error)
	  }, onCompleted: { 
	    print("Completed")
	  }, onDisposed: { //Observable과 관련된 모든 리소스가 제거된 후에 호출됨, Disposed는 Observable이 전달하는 이벤트가 아님. 리소스가 해제되는 시점에 자동으로 호출될 뿐임. 
	    print("Disposed") 
	  })

Observable.from([1, 2, 3])
	.subscribe {
	   print($0)
	} //Completed나 Error를 전달하면서 리소스는 자동으로 해제됨
```

Observable이 Completed 이벤트나 Error 이벤트로 종료된 경우 리소스는 자동으로 해제됨 그래서 리소스를 직접 해제하지 않아도 큰 문제는 없으나 공식 문서에서 직접적으로 해제하는 것을 권장하므로 직접 해제하는 게 좋음. 또한 `dispose()` 를 사용하는 것 보다 DisposeBag을 만들어 사용하는 것이 더 권장됨.





### Subscription Disposable을 실행취소에 사용하기

subscribe 메소드가 리턴하는 Disposable을 Subscription Disposable 이라고 함.

Subscription Disposable은 리소스 해제와 실행 취소에 사용됨

```swift
var disposeBag = DisposeBag()

Observable.from([1, 2, 3])
	.subscribe {
	  print($0)
	}
	.disposed(by: disposeBag)

disposeBag = DisposeBag()		
```

새로운 DisposeBag을 만들면, 이전에 있던 DisposeBag이 해제됨. View LifeCycle 등 이용해서 해제하면 됨.

혹은 변수를 Optional 타입으로 만들고 nil을 설정할 수도 있음.

<br>



```swift
// 1초마다 정수를 전달하는 Observable
let subscription = Observable<Int>.interval(.second(1),
                                            scheduler: MainScheduler.instance)
		  .subscribe(onNext: { element in
                    print("Next", element)
                  }, onError: { error in
                    print("Error", error)
                  }, onCompleted: { 
                    print("Completed")
                  }, onDisposed: {
                    print("Disposed") 
                  })

// 3초 뒤에 dispose 함
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  subscription.dispose()
}

/* 출력
Next 0
Next 1
Next 2
Disposed
*/
```



`dispose()` 가 호출되는 즉시 모든 리소스가 해제되므로 더이상 이벤트가 전달되지 않음. 그래서 Next 다음에 Completed 이벤트가 전달되지 않았음.

그러므로 `dispose()` 를 직접적으로 호출하는 것은 가능한 피해야 함. 

만약 특정 시점에 해제해야 한다면 take, until과 같은 메소드를 사용하면 됨.

