import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rent2park/ui/main/help/Legal.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/app_strings.dart';
import '../../../util/constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(
          AppText.HELP,
          style: TextStyle(
              color: Constants.COLOR_ON_PRIMARY,
              fontFamily: Constants.GILROY_BOLD,
              fontSize: 18),
          textAlign: TextAlign.center,
        ),

        leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.pop(context),
            splashRadius: 25,
            color: Constants.COLOR_ON_PRIMARY),
      ),

      body: SafeArea(

        child: Container(
          child: Column(
            children: [
              SizedBox(height: 14,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: (){
                    launch("tel://9876543214");
                  },
                  child: SizedBox(
                    width: size.width,
                    height: 60,
                    child: Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                        color: Constants.COLOR_PRIMARY,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/icon_phone_call.svg"),
                            SizedBox(width: 10,),
                            Text(AppText.CALL_US,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          ],
                        )),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () async{
                   launchEmail(
                     toEmail:"support@rent2park.com",
                     subject:"Help",
                     message:""
                   );
                  },
                  child: SizedBox(
                    width: size.width,
                    height: 60,
                    child: Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                        color: Constants.COLOR_PRIMARY,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/email.svg"),
                            SizedBox(width: 10,),
                            Text(AppText.EMAIL_US,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          ],
                        )),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: (){},
                  child: SizedBox(
                    width: size.width,
                    height: 60,
                    child: Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                        color: Constants.COLOR_PRIMARY,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/message_icon.png",height: 26,),
                            SizedBox(width: 10,),
                            Text(AppText.CHAT_WITH_US,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          ],
                        )),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 2.0),
                      child: InkWell(
                        onTap: (){

                        },
                        child: SizedBox(
                          height: 60,
                          child: Card(
                              elevation: 4,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                              color: Constants.COLOR_PRIMARY,
                              child: Center(
                                child: Text(AppText.FAQ,
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_SEMI_BOLD,
                                        fontSize: 18)),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0,left: 2.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Legal()));
                        },
                        child: SizedBox(
                          height: 60,
                          child: Card(
                              elevation: 4,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                              color: Constants.COLOR_PRIMARY,
                              child: Center(
                                child: Text(AppText.LEGAL,
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_SEMI_BOLD,
                                        fontSize: 18)),
                              )),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void launchEmail({required String toEmail, required String subject, required String message}) async{
    final url = 'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}';
    Uri emailUrl = Uri.parse(url);
    if(await canLaunchUrl(emailUrl)){
      await launchUrl(emailUrl);
    }
  }
}
