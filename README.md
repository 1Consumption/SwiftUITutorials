# SwiftUITutorials
SwiftUI를 써보자



목차

* [Building Lists and Navigation](#building-lists-and-navigation)
* [Handling User Input](#handling-user-input)



## Building Lists and Navigation

> 참고
>
> .previewLayout(.fixed(width: 300, height: 70))
>
> -> preview를 300 * 70의 크기로 보여준다.
>
> 
>
> Group을 사용하면 여러개의 `View`를 preview로 볼 때, 한번에 preview size를 정해줄 수 있다.

### List 만들기

여러개의 `View`를 보여줄 때 `List`를 사용한다. SwiftUI의 `List`를 사용하면 모델만큼 동적으로 `View`를 만들어 줄 수 있다.(`UIKit`의 `UITableView`와 비슷하게 생겼다.)

`List` 를 만들 때는 매개변수로 모델 배열(id를 포함해야 함)과 모델의 id, 그리고 그 모델을 이용해 `View` 를 만드는 closure를 받는다.

``` swift
var body: some View {
    List(landmarkData, id: \.id) { landmark in
        LandmarkRow(landmark: landmark)
    }
}
```



그리고 모델에 `Identifiable` 프로토콜을 채택하면 id 매개변수 써주지 않아도 된다.

``` swift
struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
  
struct LandmarkList: View {
    var body: some View {
        List(landmarkData) { landmark in
            LandmarkRow(landmark: landmark)
        }
```



### Navigation

우리가 `UIKit` 에서 알고있던 `UINavigationBar` 와 비슷하다. `.navigationBarTitle(_:)` modifier를 통해 title을 변경할 수 있다. 하지만 이 메소드는 deprecated 되었기 때문에 `.navagationTitle(_:)`  메소드를 사용하자.

```swift
var body: some View {
    NavigationView {
        List(landmarkData) { landmark in
            LandmarkRow(landmark: landmark)
        }
        .navigationBarTitle(Text("Landmarks"))
    }
}
```



이제 `List` 의 `Row` 에 `NavigationLink` 를 추가해서 각 `Row`에 맞는 detail 화면으로 가도록 해보자. `List`의 closure 내부에는 `NavigationLink` 가 `View` 를 반환하는데, 이는 destination이 `LandMarkDetail` 인 `Row` 를 반환하는 것 같다. 

``` swift
NavigationView {
		List(landmarkData) { landmark in
				NavigationLink(destination: LandmarkDetail()) {
          	LandmarkRow(landmark: landmark)
				}
		}
		.navigationBarTitle(Text("Landmarks"))
```



> `UIHostingController` 를 SceneDelegate에서 사용하고 있는데, UIKit의 view hierarchy에 SwiftUI의 view를 넣을 때 사용한다고 한다... 
>
> 이 튜토리얼이 나왔을 때는 SwiftUI 1.0 그러니까 SwiftUI 2.0의 App 프로토콜이 없던 시절이라 UIKit 라이프 사이클을 따랐다고 한다. 그래서 UIHostingController를 사용했군. 이런걸 보면 신기술 도입이 쉽지만은 않은 것 같다.

그리고 다음 내용들은 하드코딩된 로직을 제거하고 모델을 전달해서 View를 만드는 과정을 보여준다. 그런데 약간 의아한게 model이 하는 역할이 많아진듯 하다. 약간 viewModel같기도 하고... 아직은 잘 모르겠다



### Handling User Input

이 섹션에서는 user가 filter를 toggle 했을 때의 model 변화에 따른 view 변화, button을 눌렀을 때의 model 변화에 따른 view 변화를 처리하는 법을 알려준다.

> @State 어노테이션을 붙이면 `Toggle` View에서 값을 바꿀 수 있다.
>
> @State var value = false
>
> Toggle(isOn: $value) { }
>
> 이런 식으로ㅎㅎ



그런데 여기서 문제는 "`NavigationLink` 로 타고 들어간 View에서 model의 `isFavorite` 을 바꾼 것을 어떻게 반영해줄 것인가?" 이것이 문제이다. 이를 `Combine` 프레임워크의 `ObservableObject` 프토콜을 사용해 해결한다.(Combine ㄷㄷ)

``` swift
import SwiftUI
import Combine

final class UserData: ObservableObject  {
    var showFavoritesOnly = false
    var landmarks = landmarkData
}
```



이 `ObservableObject` 을 채택하면 SwiftUI가 해당 객체를 subscibes 하고 있다가 데이터가 바뀌었을 때 새로고침이 필요한 view를 업데이트 해준다고 한다. 그리고 observable object는 subscribers가 변화를 감지할 수 있도록 변경사항을 publish 해야한다고 한다. 아래와 같이 `@Published`어노테이션을 붙여주자.

``` swift
final class UserData: ObservableObject  {
    @Published var showFavoritesOnly = false
    @Published var landmarks = landmarkData
}
```



이 `userData`는 상위 뷰에서 `environmentObject(_:)` modifier가 적용이 되어 있다면 자동적으로 얻을 수 있다고 한다. 그리고 `@EnvironmentObject` 어노테이션을 붙여주자.

``` swift
struct LandmarkList: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
				NavigationView {
						List {
            		Toggle(isOn: $userData.showFavoritesOnly) {
										Text("Favorites only")
								}
              ///...
              ForEach(userData.landmarks) { landmark in
                    if !self.userData.showFavoritesOnly || landmark.isFavorite {
                        NavigationLink(destination: LandmarkDetail(landmark: landmark)) {
							///...

```

``` swift
// SceneDelegate.swift
if let windowScene = scene as? UIWindowScene {
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UIHostingController(
        rootView: LandmarkList()
            .environmentObject(UserData())
    )
    self.window = window
    window.makeKeyAndVisible()
```



그리고 detailView에서 star를 눌러 isFavorite 값을 바꾸는데, 이를 업데이트하기 위해 `LandmarkDetail`에도 environment의 `UserData`object를 사용한다.

``` swift
struct LandmarkDetail: View {
    @EnvironmentObject var userData: UserData
    var landmark: Landmark
  
  	var body: some View {
      /// ...
      Button(action: {
        	self.userData.landmarks[self.landmarkIndex].isFavorite.toggle()
		}) {
        		if self.userData.landmarks[self.landmarkIndex].isFavorite {
              	Image(systemName: "star.fill")
              			.foregroundColor(Color.yellow)
						} else {
              	Image(systemName: "star")
              			.foregroundColor(Color.gray)
						}

    		}
      ///....
```

이런식으로 `LandmarkDetail` 에서도 SwiftUI의 environment에 있는 UserData 객체를 사용하기 때문에 `LandmarkDetail` 에서 isFavorite이 변경되면 상위 뷰인 `LandmarkList` 도 업데이트가 되는 것이다. 

튜토리얼이라 그런가 구조를 신경 안쓰고 구현하는 느낌이 강해서 아직 감을 잡기 좀 어렵다ㅠㅠ