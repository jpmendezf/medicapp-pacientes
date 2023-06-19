import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/Bookappointment.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Chat/chat.dart';
import 'model/doctor_detail_model.dart';
import 'videocall.dart';
import 'VideoCall/overlay_handler.dart';
import 'VideoCall/overlay_service.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'database/form_helper.dart';
import 'localization/localization_constant.dart';

class DoctorDetail extends StatefulWidget {
  final int? id;

  DoctorDetail({this.id});

  @override
  _DoctorDetailState createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> with TickerProviderStateMixin {
  bool loading = false;

  // List<Tab> tabList = [];
  TabController? _tabController;
  Tab? _handler;

  int? id = 0;
  int? doctorId = 0;
  String? name = "";
  String? expertise = "";
  String? appointmentFees = "";
  String? experience = "";
  dynamic rate = 0.0;
  String? desc = "";
  String education = "";
  String certificate = "";
  String? fullImage = "";
  String? treatmentName = "";

  String? mobileNo = "";

  List<String?> degree = [];
  List<String?> collage = [];
  List<String?> degreeYear = [];

  List<String?> award = [];
  List<String?> awardYear = [];

  // List<Hosiptal> hospitalDetail = [];
  List<HospitalId> hospitalDetail = [];
  HospitalId? hospitalDetailData;

  int hospitalIndex = 0;

  List<Reviews> reviews = [];
  List<HospitalGallery> hospitalGallery = [];

  String? token = "";
  String? channelName = "";

  String? _lat = "";
  String? _lang = "";

  void initState() {
    print("InitState");
    id = widget.id;
    hospitalIndex = 0;
    // callApiDoctorDetail();
    _getAddress();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);

    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _lat = prefs.getString('lat');
        _lang = prefs.getString('lang');
        callApiDoctorDetail();
      },
    );
  }

  _addVideoOverlay(BuildContext context) {
    OverlayService().addVideosOverlay(
      context,
      VideoCall(
        id: widget.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Build");
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (Provider.of<OverlayHandlerProvider>(context, listen: false).overlayActive) {
          Provider.of<OverlayHandlerProvider>(context, listen: false).enablePip(1.8);
          return false;
        }
        return true;
      },
      child: DefaultTabController(
        // Added
        length: 3, // Added
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Palette.dark_blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            backgroundColor: Palette.white,
            title: Text(
              getTranslated(context, doctorDetail_title).toString(),
              style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
            ),
          ),
          body: ModalProgressHUD(
            inAsyncCall: loading,
            opacity: 0.5,
            progressIndicator: SpinKitFadingCircle(
              color: Palette.blue,
              size: 50.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: height * 0.06),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SafeArea(
                                        child: Container(
                                          child: new Wrap(
                                            children: <Widget>[
                                              new ListTile(
                                                leading: new Icon(Icons.phone_in_talk),
                                                title: new Text(
                                                  getTranslated(context, "call").toString(),
                                                ),
                                                onTap: () {
                                                  if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) ==
                                                      true) {
                                                    Navigator.of(context).pop();
                                                    launch("tel:$mobileNo");
                                                  } else {
                                                    Navigator.of(context).pop();
                                                    FormHelper.showMessage(
                                                      context,
                                                      getTranslated(context, "call").toString(),
                                                      getTranslated(context, "call_alert").toString(),
                                                      getTranslated(context, cancel).toString(),
                                                      () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      buttonText2: getTranslated(context, login).toString(),
                                                      isConfirmationDialog: true,
                                                      onPressed2: () {
                                                        Navigator.pushNamed(context, 'SignIn');
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                              new ListTile(
                                                leading: new Icon(Icons.videocam),
                                                title: new Text(
                                                  getTranslated(context, "videoCall").toString(),
                                                ),
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) ==
                                                          true) {
                                                        Navigator.of(context).pop();
                                                        _addVideoOverlay(context);
                                                      } else {
                                                        Navigator.of(context).pop();
                                                        FormHelper.showMessage(
                                                          context,
                                                          getTranslated(context, "videoCall").toString(),
                                                          getTranslated(context, "videoCall_alert").toString(),
                                                          getTranslated(context, cancel).toString(),
                                                          () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          buttonText2: getTranslated(context, login).toString(),
                                                          isConfirmationDialog: true,
                                                          onPressed2: () {
                                                            Navigator.pushNamed(context, 'SignIn');
                                                          },
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    'assets/icons/call.svg',
                                  ),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                height: width * 0.3,
                                child: CachedNetworkImage(
                                  alignment: Alignment.center,
                                  imageUrl: '$fullImage',
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Palette.blue,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: imageProvider,
                                    ),
                                  ),
                                  placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                  errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      "assets/images/no_image.jpg",
                                      width: width * 0.3,
                                      height: width * 0.3,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // launch("sms:$mobileNo");
                                  SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Chat(
                                              doctorId: doctorId!,
                                              where: 'DoctorDetail',
                                            ),
                                          ),
                                        )
                                      : FormHelper.showMessage(
                                          context,
                                          getTranslated(context, "doctorDetail_chat_alert_title").toString(),
                                          getTranslated(context, "doctorDetail_chat_alert_text").toString(),
                                          getTranslated(context, cancel).toString(),
                                          () {
                                            Navigator.of(context).pop();
                                          },
                                          buttonText2: getTranslated(context, login).toString(),
                                          isConfirmationDialog: true,
                                          onPressed2: () {
                                            Navigator.pushNamed(context, 'SignIn');
                                          },
                                        );
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    'assets/icons/msg.svg',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: width * 0.05),
                          child: Text(
                            '$name',
                            style: TextStyle(
                              fontSize: width * 0.05,
                              color: Palette.blue,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: width * 0.01),
                          child: Text(
                            '$treatmentName',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Palette.grey,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                    child: Text(
                                      getTranslated(context, doctorDetail_appointmentFees).toString(),
                                      style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Palette.dark_blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                          '$appointmentFees',
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                    child: Text(
                                      getTranslated(context, doctorDetail_doctorExperience).toString(),
                                      style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Palette.dark_blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      '$experience  ' + getTranslated(context, doctorDetail_year).toString(),
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                      child: Text(
                                        getTranslated(context, doctorDetail_doctorRates).toString(),
                                        style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/hart.svg',
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: width * 0.028, right: width * 0.028),
                                          child: Text(
                                            '$rate',
                                            style: TextStyle(
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.1,
                  color: Palette.dark_white,
                  padding: EdgeInsets.all(width * 0.02),
                  child: TabBar(
                    labelColor: Palette.blue,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Palette.transparent,
                    tabs: [
                      Tab(
                        child: Text(
                          getTranslated(context, doctorDetail_tab1_title).toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Tab(
                        child: Text(
                          getTranslated(context, doctorDetail_tab2_title).toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Tab(
                        child: Text(
                          getTranslated(context, doctorDetail_tab3_title).toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    unselectedLabelColor: Palette.dark_blue,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Center(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    getTranslated(context, doctorDetail_personalBio).toString(),
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(left: width * 0.05, top: height * 0.01, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    '$desc',
                                    style: TextStyle(fontSize: 13, color: Palette.grey),
                                    textAlign: TextAlign.justify,
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    getTranslated(context, doctorDetail_education).toString(),
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: degree.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(left: width * 0.05, top: width * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          child: Text(
                                            degree[index]!.toUpperCase(),
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                          ),
                                        ),
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          child: Text(
                                            collage[index]! + '.',
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                          ),
                                        ),
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          child: Text(
                                            degreeYear[index]!,
                                            style: TextStyle(
                                              fontSize: width * 0.03,
                                              color: Palette.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Center(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    getTranslated(context, doctorDetail_certificate).toString(),
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: award.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(left: width * 0.05, top: width * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Text(
                                              award[index]!,
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Text(
                                            '.  ' + awardYear[index]!,
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Center(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    getTranslated(context, doctorDetail_specialization).toString(),
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                  ),
                                ),
                              ),
                              Center(
                                  child: Container(
                                margin:
                                    EdgeInsets.only(left: width * 0.05, top: size.height * 0.01, right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  '$expertise',
                                  style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                ),
                              )),
                            ],
                          ),
                        ),

                        //tab 2
                        /*ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: hospitalDetail.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * 0.35,
                                          child: Text(
                                            getTranslated(context, doctorDetail_hospitalName).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            hospitalDetail[index].hospitalDetails!.name!,
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * 0.35,
                                          child: Text(
                                            getTranslated(context, doctorDetail_phoneNumber).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            hospitalDetail[index].hospitalDetails!.phone!,
                                            // "9876543210",
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * 0.35,
                                          child: Text(
                                            getTranslated(context, doctorDetail_address).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            maxLines: 2,
                                          ),
                                        ),
                                        Container(
                                          width: width * 0.55,
                                          child: Text(
                                            hospitalDetail[index].hospitalDetails!.address!,
                                            // "Rajkot",
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * 0.35,
                                          child: Text(
                                            getTranslated(context, doctorDetail_facility).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          ),
                                        ),
                                        Container(
                                          width: width / 3,
                                          child: Text(
                                            hospitalDetail[index].hospitalDetails!.facility!,
                                            // "2 Bed",
                                            style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                hospitalDetail[index].hospitalGallery!.length != 0
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                            child: Text(
                                              getTranslated(context, doctorDetail_image).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                                            width: width,
                                            child: GridView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: hospitalDetail[index].hospitalGallery!.length,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              itemBuilder: (context, imageIndex) {
                                                return Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      margin: EdgeInsets.all(5),
                                                      child:
                                                          // FullScreenWidget(
                                                          ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: CachedNetworkImage(
                                                          alignment: Alignment.center,
                                                          imageUrl: hospitalDetail[index]
                                                              .hospitalGallery![imageIndex]
                                                              .fullImage!,
                                                          placeholder: (context, url) =>
                                                              SpinKitFadingCircle(color: Palette.blue),
                                                          errorWidget: (context, url, error) =>
                                                              Image.asset("assets/images/NoImage.png"),
                                                          height: height * 0.2,
                                                          width: width * 0.3,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    )
                                                    // ),
                                                    );
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ],
                            );
                          },
                        ),*/
                        ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: BouncingScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * 0.35,
                                            child: Text(
                                              getTranslated(context, doctorDetail_hospitalName).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.5,
                                            child: DropdownButtonFormField(
                                              hint: Text(
                                                hospitalDetail[hospitalIndex].hospitalDetails!.name!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_blue,
                                                ),
                                              ),
                                              value: hospitalDetailData,
                                              isExpanded: true,
                                              iconSize: 25,
                                              onSaved: (dynamic value) {
                                                setState(() {
                                                  hospitalDetailData = value;
                                                  print("$hospitalDetailData");
                                                });
                                              },
                                              onChanged: (HospitalId? newValue) {
                                                setState(
                                                  () {
                                                    print("${hospitalDetail.indexOf(newValue!)}");
                                                    hospitalIndex = hospitalDetail.indexOf(newValue);
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                              validator: (dynamic value) => value == null
                                                  ? getTranslated(context, bookAppointment_patientAddress_validator1)
                                                      .toString()
                                                  : null,
                                              items: hospitalDetail.map((location) {
                                                return DropdownMenuItem<HospitalId>(
                                                  child: new Text(
                                                    location.hospitalDetails!.name!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  ),
                                                  value: location,
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * 0.35,
                                            child: Text(
                                              getTranslated(context, doctorDetail_phoneNumber).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              hospitalDetail[hospitalIndex].hospitalDetails!.phone!,
                                              // "9876543210",
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * 0.35,
                                            child: Text(
                                              getTranslated(context, doctorDetail_address).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                              maxLines: 2,
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.55,
                                            child: Text(
                                              hospitalDetail[hospitalIndex].hospitalDetails!.address!,
                                              // "Rajkot",
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * 0.35,
                                            child: Text(
                                              getTranslated(context, doctorDetail_facility).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Container(
                                            width: width / 3,
                                            child: Text(
                                              hospitalDetail[hospitalIndex].hospitalDetails!.facility!,
                                              // "2 Bed",
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  hospitalDetail[hospitalIndex].hospitalGallery!.length != 0
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                              child: Text(
                                                getTranslated(context, doctorDetail_image).toString(),
                                                style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                                              width: width,
                                              child: GridView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: hospitalDetail[hospitalIndex].hospitalGallery!.length,
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                ),
                                                itemBuilder: (context, imageIndex) {
                                                  return Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        margin: EdgeInsets.all(5),
                                                        child:
                                                            // FullScreenWidget(
                                                            ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: CachedNetworkImage(
                                                            alignment: Alignment.center,
                                                            imageUrl: hospitalDetail[hospitalIndex]
                                                                .hospitalGallery![imageIndex]
                                                                .fullImage!,
                                                            placeholder: (context, url) =>
                                                                SpinKitFadingCircle(color: Palette.blue),
                                                            errorWidget: (context, url, error) =>
                                                                Image.asset("assets/images/NoImage.png"),
                                                            height: height * 0.2,
                                                            width: width * 0.3,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      )
                                                      // ),
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              );
                            }),

                        //tab 3
                        reviews.length != 0
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: width * 0.05, top: size.height * 0.02, right: width * 0.05),
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          getTranslated(context, doctorDetail_review).toString(),
                                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                        ),
                                      ),
                                    ),
                                    reviews.length != 0
                                        ? ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: reviews.length,
                                            itemBuilder: (context, index) {
                                              String date =
                                                  DateUtil().formattedDate(DateTime.parse(reviews[index].createdAt!));
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  left: width * 0.02,
                                                  right: width * 0.02,
                                                ),
                                                width: width * 0.87,
                                                height: height * 0.1,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: ListTile(
                                                        isThreeLine: true,
                                                        leading: SizedBox(
                                                          child: Container(
                                                            height: height * 0.062,
                                                            width: width * 0.125,
                                                            decoration:
                                                                new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                                              new BoxShadow(
                                                                color: Palette.blue,
                                                                blurRadius: 1.0,
                                                              ),
                                                            ]),
                                                            child: CachedNetworkImage(
                                                              alignment: Alignment.center,
                                                              imageUrl: reviews[index].user!.fullImage!,
                                                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                radius: 50,
                                                                backgroundColor: Palette.white,
                                                                child: CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundImage: imageProvider,
                                                                ),
                                                              ),
                                                              placeholder: (context, url) =>
                                                                  SpinKitFadingCircle(color: Palette.dark_blue),
                                                              errorWidget: (context, url, error) => ClipRRect(
                                                                borderRadius: BorderRadius.circular(50),
                                                                child: Image.asset(
                                                                  "assets/images/no_image.jpg",
                                                                  fit: BoxFit.fitHeight,
                                                                  width: 60,
                                                                  height: 60,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        title: Column(
                                                          children: [
                                                            Container(
                                                              alignment: AlignmentDirectional.topStart,
                                                              margin: EdgeInsets.only(
                                                                top: height * 0.01,
                                                              ),
                                                              child: Text(
                                                                reviews[index].user!.name!,
                                                                style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment: AlignmentDirectional.topStart,
                                                              child: Text(
                                                                '$date',
                                                                style: TextStyle(fontSize: 11, color: Palette.grey),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: Container(
                                                          child: RatingBarIndicator(
                                                            rating: reviews[index].rate!.toDouble(),
                                                            itemBuilder: (context, index) => Icon(
                                                              Icons.star,
                                                              color: Palette.blue,
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: width * 0.04,
                                                            direction: Axis.horizontal,
                                                          ),
                                                        ),
                                                        subtitle: Container(
                                                          margin: EdgeInsets.only(top: width * 0.015),
                                                          alignment: AlignmentDirectional.topStart,
                                                          child: Text(
                                                            reviews[index].review!,
                                                            style: TextStyle(fontSize: 12, color: Palette.grey),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              )
                            : Container(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  getTranslated(context, doctorDetail_noReview).toString(),
                                  style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: width * 0.12,
            child: ElevatedButton(
              child: Text(
                getTranslated(context, doctorDetail_bookAppointment).toString(),
                style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointment(id: id),
                        ),
                      )
                    : FormHelper.showMessage(
                        context,
                        getTranslated(context, doctorDetail_appointmentBook_alert_title).toString(),
                        getTranslated(context, doctorDetail_appointmentBook_alert_text).toString(),
                        getTranslated(context, cancel).toString(),
                        () {
                          Navigator.of(context).pop();
                        },
                        buttonText2: getTranslated(context, login).toString(),
                        isConfirmationDialog: true,
                        onPressed2: () {
                          Navigator.pushNamed(context, 'SignIn');
                        },
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<DoctorDetailModel>> callApiDoctorDetail() async {
    DoctorDetailModel response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).doctorDetailRequest(id, body);
      if (response.success == true) {
        setState(
          () {
            loading = false;
            id = response.data!.id;
            doctorId = response.data!.userId;
            name = response.data!.name;
            rate = response.data!.rate!.toDouble();
            experience = response.data!.experience;
            appointmentFees = response.data!.appointmentFees;
            desc = response.data!.desc;
            expertise = response.data!.expertise!.name;
            fullImage = response.data!.fullImage;
            treatmentName = response.data!.treatment!.name;
            reviews.addAll(response.data!.reviews!);

            hospitalDetail.addAll(response.data!.hospitalId!);
            for (int i = 0; i < hospitalDetail.length; i++) {
              // mobileNo = hospitalDetail[i].phone;
            }
            var convertDegree = json.decode(response.data!.education!);
            degree.clear();
            collage.clear();
            degreeYear.clear();
            for (int i = 0; i < convertDegree.length; i++) {
              degree.add(convertDegree[i]['degree']);
              collage.add(convertDegree[i]['college']);
              degreeYear.add(convertDegree[i]['year']);
            }
            var convertCertificate = json.decode(response.data!.certificate!);
            award.clear();
            awardYear.clear();
            for (int i = 0; i < convertCertificate.length; i++) {
              award.add(convertCertificate[i]['certificate']);
              awardYear.add(convertCertificate[i]['certificate_year']);
            }
          },
        );
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTra_column = 23ce: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
