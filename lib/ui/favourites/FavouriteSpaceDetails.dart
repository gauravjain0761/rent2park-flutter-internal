import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rent2park/util/SizeConfig.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';


class FavouriteSpaceDetails extends StatefulWidget {
  const FavouriteSpaceDetails({Key? key}) : super(key: key);

  @override
  State<FavouriteSpaceDetails> createState() => _FavouriteSpaceDetailsState();
}

class _FavouriteSpaceDetailsState extends State<FavouriteSpaceDetails> {
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            AppText.SPACES_DETAILS,
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 18),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: Container(
          height: size.height,
          padding: EdgeInsets.all(5.0),
          color: Constants.COLOR_GREY_100,
          child: Column(
            children: [
              favouriteSpacesDetails(),
              Hero(
                tag: "book_again",
                child: RawMaterialButton(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    constraints: BoxConstraints(
                        minWidth: size.width - 45, minHeight: 40),
                    onPressed: () {
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    },
                    fillColor: Constants.COLOR_PRIMARY,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(AppText.BOOK_AGAIN,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 16)),
                    )),
              ),
            ],
          ),
        ));
  }

  Widget favouriteSpacesDetails() {
    return Container(
      margin: EdgeInsets.all(10),
      width: size.width,
      child: Wrap(
        children: [
          Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: getProportionateScreenHeight(220, size.height),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Image.asset(
                        "assets/manage-space3.jpeg",
                        height: 80,
                        width: 135,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: getProportionateScreenHeight(180, size.height),
                    left: getProportionateScreenWidth(25, size.width),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Image.asset(
                        "assets/man.png",
                        height: 80,
                        width: 80,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: getProportionateScreenHeight(6, size.height),
                    right: getProportionateScreenWidth(45, size.width),
                    child: InkWell(
                        onTap: (){
                          share();
                        },child: SvgPicture.asset("assets/share_icon.svg",height: 18,width: 18,fit: BoxFit.fill,color: Constants.COLOR_ON_SECONDARY,)),
                  ),

                  Positioned(
                    top: getProportionateScreenHeight(8, size.height),
                    right: getProportionateScreenWidth(15, size.width),
                    child:SvgPicture.asset("assets/search_heart_icon_.svg",height: 16,width: 16,fit: BoxFit.fill,),
                  ),
                  Positioned(
                    top: getProportionateScreenHeight(225, size.height),
                    right: 12,
                    child: Text(
                      "Driveway ",
                      style: TextStyle(
                          color: Constants.COLOR_BLACK,
                          fontFamily: Constants.GILROY_MEDIUM,
                          fontSize: 15),
                    ),),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getProportionateScreenHeight(225, size.height),),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 115),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Host: ",
                                  style: TextStyle(
                                      color: Constants.COLOR_PRIMARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16),
                                ),

                                SizedBox(width: 10,),
                                Text(
                                  "John Doe",
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK_200,
                                      fontFamily: Constants.GILROY_MEDIUM,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(

                                  children: [
                                    RatingBar.builder(
                                      initialRating: 4,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      itemSize: 20,
                                      unratedColor: Constants.colorDivider,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemBuilder: (context, index) => const Icon(
                                          Icons.star,
                                          size: 20,
                                          color: Constants.COLOR_SECONDARY),
                                      onRatingUpdate: (rating) {},
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("(236)",
                                        style: TextStyle(
                                            color: Constants.COLOR_BLACK_200,
                                            fontFamily: Constants.GILROY_MEDIUM,
                                            fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Spacer(),


                        ],
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text("Location:",
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text("600 NE 29th Dr, Fot Lauderdale, FL USA",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontFamily: Constants.GILROY_MEDIUM,
                                fontSize: 16)),
                      ),

                      SizedBox(height: 20,),
                      Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      SizedBox(height: 10,),

                      Align(
                        alignment: Alignment.center,
                        child: Text("Features:",
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/wifi.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text("Wifi",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/charger.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text("Charging",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/cctv.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text("CCTV",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/home.png",
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text("Sheltered",
                                    style: TextStyle(
                                        color: Constants.COLOR_BLACK_200,
                                        fontFamily: Constants.GILROY_MEDIUM,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),




                ],
              )),
        ],
      ),
    );
  }


  Future<void> share() async {
    await FlutterShare.share(
        title: 'Example share',
        text: 'Example share text',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'Example Chooser Title'
    );
  }
}
