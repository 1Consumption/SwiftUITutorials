# SwiftUITutorials
SwiftUI를 써보자



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