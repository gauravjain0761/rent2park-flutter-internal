import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/ui/favourites/FavouriteSpaceDetails.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';

class FavouriteSpaces extends StatefulWidget {
  const FavouriteSpaces({Key? key}) : super(key: key);

  @override
  State<FavouriteSpaces> createState() => _FavouriteSpacesState();
}

class _FavouriteSpacesState extends State<FavouriteSpaces> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            AppText.FAVOURITE_SPACES,
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
          padding: EdgeInsets.all(10.0),
          color: Constants.COLOR_GREY_100,
          child: favouriteSpaces(),
        ));
  }

  Widget favouriteSpaces() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FavouriteSpaceDetails()));
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18,vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0,top: 8,bottom: 8),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        child: Image.asset("assets/manage-space3.jpeg",height: 80,width: 135,fit: BoxFit.fill,),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 28.0,top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Host: ",style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 14),),
                          Text("John Joe",style: TextStyle(
                              color: Constants.COLOR_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 14),),

                          Divider(),

                          Text("Date Saved: ",style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 14),),
                          Text("30th Dec 2022",style: TextStyle(
                              color: Constants.COLOR_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 14),),
                        ],
                      ),
                    ),

                    Spacer(),

                    InkWell(
                      onTap: (){
                        share();
                      },
                        child: SvgPicture.asset("assets/share_icon.svg",height: 18,width: 18,fit: BoxFit.fill,)),
                    SizedBox(width: 12,),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: SvgPicture.asset("assets/search_heart_icon_.svg",height: 15,width: 15,fit: BoxFit.fill,),

                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Icon(Icons.arrow_forward_ios_sharp,color: Constants.COLOR_BLACK_200,size: 18,),
                        ),
                        Divider(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
