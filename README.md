# PhotosUI

## 특징 😎
- SwiftUI와 Combine을 사용해 declarative하고 reactive합니다.
- SwiftUI와 Combine을 이용한 MVVM architecture가 적용되었습니다.
- Protocol과 dependency injection으로 service layer가 testable합니다.
- NSCache와 FileManager를 활용하여 image caching을 구현했습니다.

## iOS 13에서 SwiftUI 사용 제약사항 😭
- App protocol을 사용한 App lifecycle 제어를 할 수 없어 SceneDelegate을 사용해야합니다.
- flatMap 기능 제한으로 Upstream data type 에 Failure type 이포함되어야 합니다.
- TabView에 tabViewStyle(.page) 를 사용할 수 없어 pagination이 제공되지 않습니다.
- full screen modal present 를 하기 위한 fullScreenCover(::)가 제공되지 않습니다.
- List를 programmatically하게 scroll to position하기 위한 ScrollViewReader가 없습다.
- Grid를 지원하지 않습니다.
- SwiftUI는 iOS 14 이상에서 적용하는 것을 추천합니다..

## Author

Eido Goya, eido9oya@gmail.com
