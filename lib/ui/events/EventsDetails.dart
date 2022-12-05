import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/EventSearchApiModel.dart';
import '../../util/constants.dart';

class EventDetails extends StatefulWidget {
  final EventsResults events;
  const EventDetails({Key? key, required this.events}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Size size;
  late EventsResults events;
  var currentYear = "";


  @override
  void initState() {
    currentYear = DateFormat('yyyy').format(DateTime.now());
    events = widget.events;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Padding(
            padding: EdgeInsets.only(left: 70.0),
            child: Text(
              "Events Details",
              style: TextStyle(
                  color: Constants.COLOR_ON_PRIMARY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(5.0),
            color: Constants.COLOR_GREY_100,
            width: size.width,
            child: eventData(),
          ),
        ));
  }

  Widget eventData() {
    return Column(
      children: [
        SizedBox(height: 10,),
        Card(
         shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width,
                height: size.height*0.22,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                  child: Image.network(events.thumbnail,fit: BoxFit.fill,)
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0),
                child: Text(events.title,style: TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 20)),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 8.0),
                child: Text("7:30 to 10:30 PM",style: TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 20)),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 8.0),
                child: Text("${events.date.startDate}, $currentYear",style: TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 15)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 8.0),
                child: Text("The Parker",style: TextStyle(
                    color: Constants.COLOR_PRIMARY,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 20)),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 8.0),
                child: Text(events.address[0],style: TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 20)),
              ),

              SizedBox(height: 10,)

            ],
          ),
        ),

        ///Parking Times//

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0),
                    child: Text("Reserve Parking",style: TextStyle(
                        color: Constants.COLOR_BLACK,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 18)),),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0,right:30,top: 20,bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Start:",style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),

                          Container(
                            decoration: BoxDecoration(
                                color: Constants.COLOR_PRIMARY,
                                borderRadius: BorderRadius.circular(10),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
                              child: Column(
                                children: [
                                  Text("Oct 13th, 2022",style: TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 12)),

                                  Text("7:00PM",style: TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 22)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("End:",style: TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),
                          Container(
                            decoration: BoxDecoration(
                              color: Constants.COLOR_PRIMARY,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
                              child: Column(
                                children: [
                                  Text("Oct 13th, 2022",style: TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 12)),

                                  Text("11:00PM",style: TextStyle(
                                      color: Constants.COLOR_ON_SECONDARY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 22)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
        parkingData(),
      ],
    );
  }

  Widget parkingData() {
    var parkingList = 0;
    return Container(
      width: size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0),
              child: Text("Listings:",style: TextStyle(
                  color: Constants.COLOR_BLACK_200,
                  fontFamily: Constants.GILROY_MEDIUM,
                  fontSize: 18)),
            ),

            Container(margin: EdgeInsets.symmetric(horizontal: 10,vertical: 4), height: 1,color: Constants.COLOR_GREY),

            SizedBox(height: 15,),
            parkingList>0?ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
                itemBuilder: (context,index)
                {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0,right: 12.0),
                                child: Text("Driveway",style: TextStyle(
                                    color: Constants.COLOR_BLACK,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16)),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 0.0),
                                child: Text("567 NE 7th St",style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 14)),
                              ),
                            ],
                          ),

                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text("\$46.00",style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 22)),
                              ),

                              Row(
                                children: [
                                  Icon(Icons.directions_run,color: Constants.COLOR_PRIMARY,),
                                  Text("4 mins",style: TextStyle(
                                      color: Constants.COLOR_BLACK,
                                      fontFamily: Constants.GILROY_MEDIUM,
                                      fontSize: 14)),
                                ],
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.arrow_forward_ios,color: Constants.COLOR_BLACK_200,),
                          ),
                        ],
                      ),

                      Container(margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10), height: 1,color: Constants.COLOR_GREY),
                    ],
                  );
            }):noParkingData()

          ],
        ),
      ),
    );

  }

  Widget noParkingData() {
    return Container(
      width: size.width,
      child: Column(
        children: [
          Text("There are currently no parking available",style: TextStyle(
              color: Constants.COLOR_BLACK,
              fontFamily: Constants.GILROY_BOLD,
              fontSize: 16)),

          SizedBox(height: 8,),

          Text("Have Parking near The Parking Center?",style: TextStyle(
              color: Constants.COLOR_BLACK_200,
              fontFamily: Constants.GILROY_MEDIUM,
              fontSize: 14),textAlign: TextAlign.center),

          SizedBox(height: 20,),

          Text("Become a Host on Rent2Park and earn\nMoney by renting out your space,\nit will display here",style: TextStyle(
              color: Constants.COLOR_BLACK_200,
              fontFamily: Constants.GILROY_MEDIUM,
              fontSize: 14),textAlign: TextAlign.center,),
          SizedBox(height: 15,),
          RawMaterialButton(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              constraints:
              BoxConstraints(minWidth: size.width - 200, minHeight: 40),
              onPressed: () {},
              fillColor: Constants.COLOR_PRIMARY,
              child: Text("Add Space",
                  style: const TextStyle(
                      color: Constants.COLOR_ON_PRIMARY,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 16))),
          SizedBox(height: 15,),
        ],
      ),
    );
  }
}
