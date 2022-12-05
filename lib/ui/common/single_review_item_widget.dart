import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../data/backend_responses.dart';
import '../../util/constants.dart';


class SingleReviewListTileWidget extends StatelessWidget {
  final Reviews review;

  const SingleReviewListTileWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              review.userImage == null
                  ? SizedBox(
                      width: 45,
                      height: 45,
                      child: CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/man.png',
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 45,
                      height: 45,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          review.userImage!,
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: review.userName,
                            style: const TextStyle(
                                color: Constants.COLOR_BLACK,
                                fontSize: 15,
                                fontFamily: Constants.GILROY_BOLD),
                            children: [
                          TextSpan(
                            text: '  (${review.date})',
                            style: TextStyle(
                                color: Constants.colorDivider,
                                fontFamily: Constants.GILROY_REGULAR,
                                fontSize: 13),
                          )
                        ])),
                    RatingBar.builder(
                      initialRating: review.rating.toDouble(),
                      minRating: 0,
                      direction: Axis.horizontal,
                      itemSize: 20,
                      unratedColor: Constants.colorDivider,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, index) => const Icon(Icons.star,
                          size: 20, color: Constants.COLOR_SECONDARY),
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment ?? 'No comment',
              style: const TextStyle(
                  color: Constants.COLOR_ON_SURFACE,
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 13)),
          const SizedBox(height: 10),
          Divider(height: 0.5, thickness: 0.5),
        ],
      ),
    );
  }
}
