# CoreMLDemo
From the Intro to Augmented Reality course on Udemy by Timothy Meixner & Johannes Ruof -  
An Application implementing a machine learning model with CoreML and Vision that can do live predictions as well as Augmented Reality
labels with ARKit that we are then able to add to identified objects.

A user can pan with his camera and select objects in his view. The app will predict
what the object is by using Machine learning.

firstcommit - Using boiler plate in AR set up storyboard with UIView and ARSceneView plus 2 labels. 
Connected to VC. Set up scene and added a new method for ARCamera func cameraDidChangeTrackingState() Switch statement implemented.

secondcommit - Initializing the model. This application uses the Inceptionv3 model from Apple. A method is used for the vision 
framework to access this model. The method is called initializeModel() A update method is then implemented to constantly update the 
current frame the camera is tracking.



