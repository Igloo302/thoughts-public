---
tags:
  - indie-dev
  - project
  - ios
  - log
date: 2026-01-22
status: archive
area: 2-Areas/职业发展
---

根据实测，这个 App 目前只能处理小米手机 MIUI 和 HyperOS 1 拍摄的动态照片例如 Xiaomi 1. Jpg ，而无法支持 HyperOS 2 的照片 Xiaomi 2. Jpg ，同时也无法支持三星拍摄的动态照片。

接下来，我需要对无法支持的动态照片的文件进行分析，并且在这个 App 中增加对它们的动态照片的支持。请根据这些信息，更新代码中的注释和 docs 文件夹下的信息，并在代码中为支持更多不同品牌的动态照片的能力做好模块化的准备。





[MotionPhoto / MicroVideo File Formats on Pixel Phones \| Timo's openSUSE Posts](https://timojyrinki.gitlab.io/hugo/post/2021-03-30-pixel-motionphoto-microvideo-file-formats/)





{"content": "现在，让我们来处理三星的动态照片。 \n 现状： \n 1. 能正确识别出这是动态照片 \n 2. 进入预览页面之后，长按图片不支持播放 \n \n 日志： \n Found <x:xmpmeta> tags. \n XMP Start: 53126, XMP End: 54246 \n XMP Info: [\"GCamera: MotionPhoto\": \"1\", \"GCamera: MotionPhotoPresentationTimestampUs\": \"3095755\", \"GCamera: MotionPhotoVersion\": \"1\"] \n 开始处理文件: /Users/larry. Shen/Library/Containers/8 C 433516-8 A 20-4 A 7 D-9333-1 EEE 9 D 2 C 46 EC/Data/tmp/F 7 C 31 F 95-80 AD-4 C 75-B 97 B-4 FA 6 D 4 E 3 F 205. Jpeg \n 文件大小: 9625378 bytes \n Found <x:xmpmeta> tags. \n XMP Start: 53126, XMP End: 54246 \n XMPInfo: [\"GCamera: MotionPhotoPresentationTimestampUs\": \"3095755\", \"GCamera: MotionPhoto\": \"1\", \"GCamera: MotionPhotoVersion\": \"1\"] \n 不支持的动态照片格式 \n Attempt to present <SwiftUI.PlatformAlertController: 0x14dd70000> on <_TtGC7SwiftUI32NavigationStackHostingControllerVS_7AnyView_: 0x14ddc0a00> (from <_TtGC7SwiftUI32NavigationStackHostingControllerVS_7AnyView_: 0x14ddc0a00>) whose view is not in the window hierarchy. \n IOSurface creation failed: e 00002 c 2 parentID: 00000000 properties: { \n     IOSurfaceAddress = 5019582464; \n     IOSurfaceAllocSize = 9625378; \n     IOSurfaceCacheMode = 0; \n     IOSurfaceName = CMPhoto; \n     IOSurfacePixelFormat = 1246774599; \n } \n \n \n 参考 `/Users/larry.shen/Library/CloudStorage/OneDrive-个人/Learn/Coding/MotionPhotoConverter/samples/SamsungXMP` 的信息，修改代码。","multiMedia":[],"parsedQuery":["现在，让我们来处理三星的动态照片。","\n","现状：","\n","1. 能正确识别出这是动态照片","\n","2. 进入预览页面之后，长按图片不支持播放","\n","\n","日志：","\n","Found <x:xmpmeta> tags.","\n","XMP Start: 53126, XMP End: 54246","\n","XMP Info: [\"GCamera: MotionPhoto\": \"1\", \"GCamera: MotionPhotoPresentationTimestampUs\": \"3095755\", \"GCamera: MotionPhotoVersion\": \"1\"]","\n","开始处理文件: /Users/larry. Shen/Library/Containers/8 C 433516-8 A 20-4 A 7 D-9333-1 EEE 9 D 2 C 46 EC/Data/tmp/F 7 C 31 F 95-80 AD-4 C 75-B 97 B-4 FA 6 D 4 E 3 F 205. Jpeg","\n","文件大小: 9625378 bytes","\n","Found <x:xmpmeta> tags.","\n","XMP Start: 53126, XMP End: 54246","\n","XMPInfo: [\"GCamera: MotionPhotoPresentationTimestampUs\": \"3095755\", \"GCamera: MotionPhoto\": \"1\", \"GCamera: MotionPhotoVersion\": \"1\"]","\n","不支持的动态照片格式","\n","Attempt to present <SwiftUI.PlatformAlertController: 0x14dd70000> on <_TtGC7SwiftUI32NavigationStackHostingControllerVS_7AnyView_: 0x14ddc0a00> (from <_TtGC7SwiftUI32NavigationStackHostingControllerVS_7AnyView_: 0x14ddc0a00>) whose view is not in the window hierarchy.","\n","IOSurface creation failed: e 00002 c 2 parentID: 00000000 properties: {","\n","    IOSurfaceAddress = 5019582464;","\n","    IOSurfaceAllocSize = 9625378;","\n","    IOSurfaceCacheMode = 0;","\n","    IOSurfaceName = CMPhoto;","\n","    IOSurfacePixelFormat = 1246774599;","\n","}","\n","\n","\n","参考",{"filePath": "/Users/larry. Shen/Library/CloudStorage/OneDrive-个人/Learn/Coding/MotionPhotoConverter/samples/SamsungXMP","relatePath": "samples/SamsungXMP","name": "SamsungXMP","type": "file","title": "/Users/larry. Shen/Library/CloudStorage/OneDrive-个人/Learn/Coding/MotionPhotoConverter/samples/SamsungXMP"},"的信息，修改代码。","\n"]}



{"content": "做得好！根据实测，PIxel 也已经支持了。请对界面进行调整，并且在界面上说明待支持的机型「华为」、「Vivo」、「OPPO」","multiMedia":[],"parsedQuery":["做得好！根据实测，PIxel 也已经支持了。请对界面进行调整，并且在界面上说明待支持的机型「华为」、「Vivo」、「OPPO」"]}



对于未知的动态照片格式，可以用一种兜底的处理方式，即查找文件中的ftyp，那样就不用考虑 xml 了，在动态照片的检测和处理阶段，添加这种方式作为兜底。