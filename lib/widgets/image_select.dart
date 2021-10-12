//import 'dart:js';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

//enum ImageSourceType { gallery, camera }

class ImageSelect extends StatefulWidget {
  final isCamera;
  final Function storeImage;
  ImageSelect(this.isCamera,this.storeImage);

  @override
  _ImageSelectState createState() => _ImageSelectState(isCamera,storeImage);
}

class _ImageSelectState extends State<ImageSelect> {
  File? _image;
  var imagePicker;
  final isCamera;
  final Function storeImage;

  _ImageSelectState(this.isCamera, this.storeImage);

  @override
  void initState() {
    print(isCamera);
    super.initState();
    imagePicker = new ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    double _imgBoxHeight = MediaQuery.of(context).size.height * 0.35;
    double _imgBoxWidth = MediaQuery.of(context).size.width * 0.70;

    return Column(
        children: <Widget>[
          SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var source = isCamera
                    ? ImageSource.camera
                    : ImageSource.gallery;
                try{
                  final image = await imagePicker.pickImage(
                      source: source, imageQuality: 50, preferredCameraDevice: CameraDevice.front)
                  ;
                  setState(() {
                    _image = File(image.path);
                    storeImage('picture',image.path);
                  });
                } catch(err) {
                  print(err);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("No image selected."),
                  ));
                }
              },
              child: Container(
                width: _imgBoxWidth,
                height: _imgBoxHeight,
                decoration: BoxDecoration(
                    border: Border.all()
                ),
                child: _image != null
                    ? Image.file(
                          _image!,
                          fit: BoxFit.fitHeight,
                        )
                    : Container(
                        width: _imgBoxWidth,
                        height: _imgBoxHeight,
                        child: isCamera 
                          ? FittedBox(
                            child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            fit: BoxFit.fill,
                          )
                          : FittedBox(
                            child: Icon(
                                Icons.folder,
                                color: Colors.grey[800],
                              ),
                              fit: BoxFit.fill,
                          )
                    )
              ),
            ),
          )
        ],
      );
  }
}