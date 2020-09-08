# RxCoCoa

Cocoa Framework에 Reactive Library를 접목한 라이브러리

UIControl과 다른 SDK 클래스를 wrapping한 커스텀 extension set

iOS, macOS, watchOS등 모든 플랫폼에서 동작



## Binding

**Data Producer** - Observable 타입을 채용한 모든 형식이 데이터 생산자가 됨

**Data Consumer** - UILabel, UIImageView와 같은 UIComponent



생산자가 생산한 데이터는 소비자에게 전달되고 소비자는 적절한 방식으로 데이터를 소비함. 

반대로 소비자가 생산자에게 데이터나 이벤트를 전달하는 경우는 없음 



### Binder

- 데이터 소비자의 역할을 수행
- `bind(to:)`  은 Observable이 방출한 이벤트를 Observer에게 전달
- Observer이기 때문에 바인더로 새로운 값을 전달할 수 있지만, Observable은 아니기 때문에 구독자를 추가하는 것은 불가능함
- Error이벤트를 받지 않음. Error를 받게되면 실행모드에 따라 크래시가 발생하거나 에러 메시지가 출력됨
  - Error이벤트가 발생하면 Observable Sequence가 종료되고 바인딩된 UI가 더이상 업데이트 되지 않음 그래서 Error 이벤트를 받지 않는다
- bind가 성공하면 UI가 업데이트 됨. binder는 binding이 메인 스레드에서 실행되는 것을 보장함



<br>

## Traits

- UI에 특화된 Observable이고 UI Binder에서 데이터 생산자 역할을 수행함 
- ControlProperty, ControlEvent, Driver, Signal이 있음
- 모든 작업은 메인 스레드에서 수행됨. 그래서 UI 업데이트 코드를 쓸 때 스케줄러를 직접 지정해주지 않아도 된다
- Error 이벤트를 전달하지 않음. 그래서 UI가 항상 올바른 스레드에서 업데이트 되는 것을 보장함

- Observable을 구독하면 새로운 시퀀스가 시작되는데, traits는 새로운 시퀀스가 시작되지 않음.

- Signal을 제외한 나머지 traits를 구독하는 모든 구독자는 동일한 시퀀스를 공유함. 일반 Observer에서 `share()`를 사용한 것과 동일한 방식으로 동작



UI 구현에 있어서 필수는 아니라 `subscirbe()` 메소드 사용해도 문제는 없음. 단지 코드가 지저분해지고 UI 코드가 잘못된 스레드에서 실행될 가능성이 높아질 뿐. 

항상 메인 스레드에서 UI 코드를 실행해주고 코드를 단순하게 작성할 수 있으므로 활용하는 것이 좋음.



<br>

### Control Property

Subject와 같이 Observabel이자 Observer. 데이터를 특정 UI에 바인딩할 때 사용.

```swift
public protocol ControlPropertyType: ObservableType, ObserverType {
  ///...
}

public struct ControlProperty<PropertyType>: ControlPropertyType {
  ///...
}
```

- Error 이벤트를 전달받지도, 전달하지도 않음
- Completed 이벤트는 컨트롤이 제거되기 직전에 전달됨
- 모든 이벤트는 메인 스케줄러에서 전달됨
- Sequence를 공유(일반 Observable에서 share(replay: 1) 한 것과 동일하게 작동. 그래서 새로운 구독자가 추가되면 가장 최근에 전달된 속성값이 바로 추가됨



<br>

### Control Event

컨트롤의 event를 수신하기 위해 사용

```swift
public protocol ContolEventType: ObservableType {
  ///...
}

public struct ControlEvent<PropertyType>: ControlEventType {
  ///...
}
```

- ObservableType만 채택하므로 Observable의 역할만 수행하고 Observer의 역할은 수행하지 않음
- Error 이벤트를 전달하지 않고 Completed 이벤트는 컨트롤이 해제되기 직전에 전달됨
- 메인 스케줄러에서 이벤트를 전달
- 가장 최근 이벤트를 replay 하지 않음
  - 그래서 새로운 구독자는 구독 이후에 전달된 이벤트만 전달받음

<br>

### Driver

- Error 이벤트 전달하지 않음

- 스케줄러를 강제로 변경하지 않는 이상 항상 메인 스케줄러에서 작동

- Shares Effect

  - 일반 Observable에서 `share(replay: 1, scope: .whileConnected)` 수행한 것과 같은 동작
  - 모든 구독자가 시퀀스를 공유하고, 새로운 구독이 시작되면 가장 최근에 전달된 이벤트가 즉시 전달됨
  - 스케줄러를 공유하므로 불필요한 리소스 낭비를 막아줌

- 직접 Driver를 생성하지 않고 `asDriver()` 메소드를 사용함 

- Driver 이용 시, `bind(to:)`사용하지 않고 `drive()` 메소드 사용

  