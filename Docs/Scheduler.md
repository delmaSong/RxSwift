# Scheduler

특정 코드가 실행되는 컨텍스트를 추상화해놓은 것

컨텍스트는 low level thread, DispatchQueue, OperationQueue가 될 수 있다.

스케줄러는 컨텍스트가 추상화된 것이라 쓰레드와 1:1로 매칭되지 않음

하나의 스레드에 2개 이상의 개별 스케쥴러가 존재하거나 하나의 스케쥴러가 두개의 스레드에 걸쳐있는 경우도 있음

큰틀에서 보면 GCD와 유사

| GCD           | RxSwift              |
| ------------- | -------------------- |
| Main Queue    | Main Scheduler       |
| Gloable Queue | Background Scheduler |

<br>

## RxSwift의 기본 Scheduler

<br>

### Serial Scheduler

- CurrentThreadScheduler : 스케쥴러를 별도로 지정하지 않았을 때의 디폴트 스케쥴러

- MainScheduler: Main Queue처럼 UI를 업데이트 할 때 사용. SerialDispatchQueueScheduler의 일종

- SerialDispatchQueueScheduler



### Concurrent Scheduler

- ConcurrentDispatchScheduler
- OperationQueueScheduler: 실행 순서를 제어하거나, 동시에 실행할 작업 수를 제한할 때 사용. DispatchQueue가 아닌 OperationQueue를 이용해 생성함

<br>



## Scheduler를 지정하는 방법

```swift
let disposeBag = DisposeBag()
let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
```



### observeOn(_:)

이어지는 연산자들이 작업을 실행할 스케쥴러를 지정

앞에 쓰여진 코드에는 영향을 미치지 않고, 지정된 다음의 코드부터

observeOn(_:)로 지정한 스케쥴러는 다른 스케쥴러로 변경하기 전까지 계속 사용됨

### subscribeOn(_:)

구독을 시작하고, 종료할 때 사용할 스케쥴러를 지정

이벤트를 방출할 스케쥴러를 지정(언제 쓰여졌든 첫 코드부터 해당 스케쥴러로 지정됨)

이 메소드를 사용하지 않으면 subscribe 시점부터 새로운 스케쥴러에서 수행됨 