# Reactor Kit

단방향 데이터 흐름을 가진 반응형 앱을 위한 프레임워크

<br>

**필요성**

1. Massive View Controller
   - 이미 많은 사람들이 공감하는 문제
   - 해결하기 위한 여러 설계 패턴들이 존재
2. RxSwift is Awesome
   - 비동기 코드를 간결하게 사용할 수 있음
   - 어렵지만 잘 쓰면 파워풀한 기술

<br>

## 특징

1. Massive View Controller를 피함
   - 뷰와 로직의 관심사 분리 -> 뷰 컨트롤러가 단순해짐
     - 뷰 컨트롤러는 렌더링하는 역할만 수행 / 로직은 Reactor라는 별도의 레이어에서 수행
2. RxSwift의 장점을 모두 취함
   - ReactorKit은 RxSwift를 기반으로 하므로, 모든 RxSwift 기능을 사용 가능
3. 쉬운 상태관리
   - 단방향 데이터 흐름 - 상태를 변경하거나 읽을 때 모두 단방향으로만 가능
   - 중간 상태를 reduce() 함수로 관리
   - 상태 관리가 간결해짐
4. 특정 기능에 부분적으로 적용 가능
5. 테스트를 위한 도구를 자체적으로 지원

<br>

## Basic Concept

<img src="https://user-images.githubusercontent.com/40784518/92367937-099a7e00-f132-11ea-8067-b39568598371.png" width=80%/>



<br>

### View

- 사용자의 입력을 받아서 Reactor에 전달
- Reactor로부터 받은 상태를 렌더링
- 뷰 컨트롤러, 셀, 컨트롤 등을 모두 View로 취급

```swift
protocol View {
  associatedtype Reactor
  var disposeBag: DisposeBag
  
  //self.reactor가 바뀌면 호출됨
  func bind(reactor: Reactor)
}
```

뷰라는 프로토콜을 적용하면 Reactor 속성이 자동으로 생김. 이 Reactor에 새로운 값을 넣을 때마다 `bind(reactor:)` 가 호출됨



```swift
//Storyboard 사용하는 경우
protocol StoryboardView {
  associatedtype Reactor
  var disposeBag: DisposeBag
  
  //뷰가 로드되면 호출됨
  func bind(reactor: Reactor)
}
```

나머지는 다 똑같지만, 뷰가 호출된 이후에   `bind(reactor:)`  호출됨을 보장해줌



### Reactor

- View에서 전달받은 Action에 따라 로직 수행
- 상태를 관리하고 상태가 변경되면 View에 전달
- 대부분의 View는 대응되는 Reactor를 가짐

```swift
import ReactorKit
import RxSwift

protocol Reactor {
  associatedtype Action			// 사용자 인터랙션 표현
  associatedtype Mutation		// State를 변경하는 가장 작은 단위
  associatedtype State			// 뷰의 상태 표현
  
  var initialState: State		//가장 첫 상태를 나타냄
}

final class UserViewReactor: Reactor {
  enum Action {
    case follow
  }
  
  enum Mutation {
    case setFollowing(Bool)
  }
  
  enum State {
    var isFollowing: Bool
  }
  
  let initialState: State = State(isFollowing: false)
}
```

비동기 타임에 State가 변경되는 경우가 있는데, Action과 State 사이에 Mutation을 둬서 비동기처리를 함

Action이나 State와 달리 Mutation은 리액터 클래스 밖으로 노출되지 않음. 대신 클래스 내부에서 Action과 State를 연결하는 역할을 수행함.



<br>



<img src="https://user-images.githubusercontent.com/40784518/92367805-dd7efd00-f131-11ea-989c-a548a402bbe9.png" width=90%/>

<br>



```swift
/*
Action 스트림을 Mutation 스트림으로 변환하는 역할
네트워킹이나 비동기로직 등의 사이드 이펙트 처리
결과로 Mutation 값을 방출하면 그 값이 reduce()로 전달됨
*/
func mutate(action: Action) -> Observable<Mutation> {
  switch action {
    case .follow:
    	return UserService.follow()
    		.map { Mutation.setFollowing(true) }
    		.catchErrorJustReturn(Mutation.setFollowing(false))
    case .unfollow:
    	return UserService.unfollow()
    		.map { Mutation.setFollowing(false) }
    		.catchErrorJustReturn(Mutation.setFollowing(true))
  }
}

/*
이전 상태와 mutate()가 방출한 Mutation을 받아서 다음 상태를 반환
*/
func reduce(state: State, mutation: Mutation) -> State {
  var newState = state
  switch mutation {
    case let setFollowing(isFollowing):
    	newState.isFollowing = isFollowing
  }
  return newState
}
```





**References**

- [ReactorKit으로 단방향 반응형 앱 만들기](https://www.youtube.com/watch?v=ASwBnMJNUK4&list=PLAHa1zfLtLiMdLjlf8VdsJeze-S1YXSKz&index=10)
- [ReactorKit 시작하기](https://medium.com/styleshare/reactorkit-시작하기-c7b52fbb131a)

