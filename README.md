![logo](https://cloud.githubusercontent.com/assets/3276768/16144347/de439bb8-34a4-11e6-8ef4-ea6925a6b3f0.png)

# Facemotion

**Facemotion** it's an iOS app, allowing you to find easily a contact by *face recognition*.
Scan the face of a person, whether the contact is in the local storage, it can be detected by the recognition algorithm. Or add the detected frames to a new contact among your own iOS contacts. And then can be recognise later by the application.



              |  Features
--------------------------|------------------------------------------------------------
:girl: | Face detection
:triangular_ruler: | Angle detection, to help you to take the best frames, and increase the chance of recognition
:mag: | Face recognition 
:chart_with_upwards_trend: | improving recognition by adding more frames to a contact


![recordcapture](https://cloud.githubusercontent.com/assets/3276768/16144253/4e96344e-34a4-11e6-9257-06f5bcdf06ef.gif)
![recordcontact](https://cloud.githubusercontent.com/assets/3276768/16144252/4e931cf0-34a4-11e6-8a17-cb6d1fca60b8.gif)


## 💻🎉 Technologies

- **Realm** database to store detected face and contact lists
- **OpenCV** for faces recognition algorithm / image processing
- **AVFoundation** for face detection / some image processing

## Installation and usage

First thing to do is to install the pods.
I choosed a pod for **opencv**, instead a built framework for easy integration. It can take a long time compiling. (1 hour macbook 13 inch 😬😿)
```
pod install
```

Run the project on a real device. 🍔

If you like it, please give me a :star:

made in 同济 with ❤️
