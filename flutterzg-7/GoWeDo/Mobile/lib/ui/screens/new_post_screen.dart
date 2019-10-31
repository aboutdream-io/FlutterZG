import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gowedo/bloc/new_post_bloc.dart';
import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/models/post.dart';
import 'package:gowedo/ui/widgets/confirm_button.dart';
import 'package:gowedo/util/dependency_injection.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_images.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/util.dart';
import 'package:image_picker/image_picker.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  NewPostBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc ??= NewPostBloc(Injector.of(context).postRepository, MyLocalization.of(context));
    return StreamBuilder<NewPostState>(
        initialData: NewPostState(stateType: StateType.waiting),
        stream: _bloc.stateStream,
        builder: (context, snapshot) {
          if (snapshot.data?.stateType == StateType.loading) {
            doAfterBuild(() => showLoadingDialog(context));
          } else {
            doAfterBuild(() => dismissLoadingDialog(context));
          }

          if (snapshot.data?.stateType == StateType.error) {
            doAfterBuild(() => showErrorDialog(context, snapshot.data.message, error: snapshot.data.error));
          }

          if (snapshot.data?.stateType == StateType.finished) {
            doAfterBuild(() => Navigator.of(context).pop(snapshot.data.post));
          }

          return Scaffold(
              appBar: AppBar(
                brightness: Brightness.dark,
                elevation: 0.0,
                iconTheme: IconThemeData(
                  color: MyColors.goWeDoWhite,
                ),
                title: Text(MyLocalization.of(context).newPost, style: TextStyle(color: MyColors.goWeDoWhite),),
                centerTitle: true,
                automaticallyImplyLeading: true,
                actions: <Widget>[
                  snapshot.data?.image != null ? InkWell(
                    onTap: _bloc.removeImage,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Icon(Icons.close, size: 28,),
                    ),
                  ) : const SizedBox()
                ],
              ),
              body: SingleChildScrollView(
                  child: _buildInputForm(snapshot)
              )
          );
        }
    );
  }

  Widget _buildInputForm(AsyncSnapshot<NewPostState> snapshot) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.8,
              color: MyColors.goWeDoBlue,
              child: Container(
                  margin: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25.0, top: 5),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: MyColors.goWeDoBlue,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          width: 2,
                          color: MyColors.goWeDoWhite)
                  ),
                  child: snapshot.data.stateType == StateType.loading
                      ? _buildProgressBar()
                      : AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          child: snapshot.data?.image == null
                            ? _buildImageUploadContainer(snapshot.data.image)
                            : _buildImage(snapshot.data.image),
                  )
              )
          ),
          const SizedBox(height: 24,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: MyLocalization.of(context).title,
                      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
                  ),
                  autovalidate: _titleController.text.isNotEmpty,
                  controller: _titleController,
                  validator: (input) => input.isEmpty ? MyLocalization.of(context).noTitle : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: MyLocalization.of(context).description,
                      labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)
                  ),
                  autovalidate: _descriptionController.text.isNotEmpty,
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (input) => input.isEmpty ? MyLocalization.of(context).noDescription : null,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ConfirmButton(
                    title: MyLocalization.of(context).create,
                    onTap: () => _createPost(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        image: snapshot.data?.image
                    )
                )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageUploadContainer(File image) {
    return InkWell(
        onTap: () async {
          var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
          _bloc.addImage(_image);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(MyImages.govedo, height: 120,),
            const SizedBox(height: 16,),
            Center(
                child: FormField(
                    autovalidate: false,
                    initialValue: true,
                    validator: (_) =>
                    image == null ? MyLocalization.of(context).noImage : null,
                    builder: (state) {
                      return Text(
                          state.errorText == null
                              ? MyLocalization.of(context).uploadImage
                              : state.errorText,
                          style: TextStyle(
                              color: state.errorText == null
                                  ? MyColors.goWeDoWhite
                                  : MyColors.goWeDoErrorColor,
                              fontWeight: FontWeight.w600));
                    }
                )
            )
          ],
        )
    );
  }

  Widget _buildImage(File image) {
    return Image.file(
      image,
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.8,
    );
  }

  Widget _buildProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  void _createPost({String title, String description, File image}) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _bloc.createPost(Post.dummyFromFile(title, description, image));
  }

  @override
  void dispose() {
    _descriptionController?.dispose();
    _titleController?.dispose();
    _bloc?.dispose();
    super.dispose();
  }
}
