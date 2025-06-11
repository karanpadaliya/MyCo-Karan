import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../jenil_file/bottomsheet_otp.dart';
import '../jenil_file/bottomsheet_radio_btn.dart';
import '../jenil_file/bottomsheet_travel_mode.dart';
import '../jenil_file/myco_custom_tabbar.dart';
import '../karan_file/SegmentedProgressBar.dart';
import '../karan_file/new_myco_button.dart';
import '../main.dart';
import '../maulik_file/current_opening_card.dart';
import '../maulik_file/ios_calendar_time_picker.dart';
import '../maulik_file/qr_scanner_page.dart';
import '../maulik_file/see_less_more_widget.dart';
import '../maulik_file/wfh_box.dart';
import '../maulik_file/work_report_add_box.dart';
import '../maulik_file/work_report_history_box.dart';
import '../rishi_file/segmented_circular_timer.dart';
import '../themes_colors/colors.dart';
import '../tirth_file/custom_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String scannedResult = 'ScannerData';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              SegmentedProgressBar(
                maxMinutes: 60,
                minutesPerSegment: 10,
                strokeWidth: 20,
                sectionGap: 2,
                backgroundColor: Colors.grey.shade300,
                primaryColor: Colors.teal,
                colorRanges: [
                  ColorRange(9, 12, Colors.red),
                  ColorRange(18, 25, Colors.orange),
                ],
              ),


              // SegmentedCircularTimer(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyCustomTabBar(
                  isShadowTopLeft: true,
                  tabs: [
                    'Active Assets (5)',
                    'Active Assets (5)',
                    // 'Active Assets (5)',
                  ],
                  selectedBgColor: Colors.teal,
                  unselectedBorderAndTextColor: AppColors.secondPrimary,
                  tabBarBorderColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyCustomTabBar(
                  isShadowBottomLeft: true,
                  tabs: ['All Assets', 'Active Assets', 'Past Assets'],
                  selectedBgColor: Colors.teal,
                  unselectedBorderAndTextColor: AppColors.secondPrimary,
                  tabBarBorderColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageGridPreviewWidget(
                  imageList: [
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScGtiKpXZ_FM45KQwYycH4jjImU6ja0jpz6Sw38tr3UxtgcWyDJAkRA4pbgxhv2dI2dZ8&usqp=CAU",
                    "https://c4.wallpaperflare.com/wallpaper/151/18/347/car-lamborghini-dark-wallpaper-preview.jpg",
                    "https://nemesisuk.com/cdn/shop/files/RoushTrakPakLifestyleShoot32-XL_6aea9414-75fc-4c98-9dcb-6b97dd2df1f2.jpg?v=1716301158",
                    "https://c4.wallpaperflare.com/wallpaper/217/249/131/lamborghini-aventador-sports-car-cool-black-car-wallpaper-preview.jpg",
                    "https://bugatti-newsroom.imgix.net/fc5cfcbe-f01f-4ee2-b664-d26ed3ca11db/01_LVN_34-Front",
                  ],
                  boxHeight: 120,
                  boxWidth: 120,
                  showIndicators: true,
                ),
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "Travel mode Bottom Sheet",
                boarderRadius: 50,
                isShadowBottomLeft: true,
                isShadowBottomRight: true,
                textStyle: TextStyle(color: AppColors.primary),
                backgroundColor: AppColors.white,
                borderColor: Colors.blue,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => OutOfRangeBottomSheet(imageMargin: 0),
                  );
                },
              ),
              const SizedBox(height: 50),
              MyCoButton(
                title: "Travel mode Bottom Sheet",
                boarderRadius: 50,
                isShadowTopLeft: true,
                isShadowTopRight: true,
                // isShadowBottomLeft: true,
                // isShadowBottomRight: true,
                textStyle: TextStyle(color: AppColors.primary),
                backgroundColor: AppColors.white,
                borderColor: Colors.blue,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => OutOfRangeBottomSheet(imageMargin: 0),
                  );
                },
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "Travel mode Alert dialog",
                boarderRadius: 50,
                isShadowBottomLeft: true,
                backgroundColor: Colors.cyan.shade200,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.white,
                        content: OutOfRangeBottomSheet(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "BottomSheet RadioButton Alert",
                boarderRadius: 50,
                isShadowBottomRight: true,
                backgroundColor: Colors.cyan.shade200,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.white,
                        content: BottomsheetRadioButton(
                          items: [
                            {
                              "id": "1",
                              "title": "Delta Corporation Pvt. Ltd",
                              "subtitle":
                                  "A-305 3rd Floor Azure Corporation Trade Tower Starlight Sarkhej, Ahmedabad Gujarat 380042",
                            },
                            {
                              "id": "2",
                              "title": "Communities heritage Pvt. Ltd",
                              "subtitle":
                                  "A-Block, 5th Floor, WTT, World Trade Tower, Makarba, Sarkhej, Ahmedabad Gujarat 380051",
                            },
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "BottomSheet RadioButton",
                boarderRadius: 50,
                isShadowTopLeft: true,
                backgroundColor: Colors.cyan.shade200,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (_) => BottomsheetRadioButton(
                          image: AssetImage("assets/tiger.jpeg"),
                          showSnackBar: true,
                          items: [
                            {
                              "id": "1",
                              "title": "Delta Corporation Pvt. Ltd",
                              "subtitle":
                                  "A-305 3rd Floor Azure Corporation Trade Tower Starlight Sarkhej, Ahmedabad Gujarat 380042",
                            },
                            {
                              "id": "2",
                              "title": "Communities heritage Pvt. Ltd",
                              "subtitle":
                                  "A-Block, 5th Floor, WTT, World Trade Tower, Makarba, Sarkhej, Ahmedabad Gujarat 380051",
                            },
                            {
                              "id": "3",
                              "title": "Belta Corporation Pvt. Ltd",
                              "subtitle":
                                  "A-305 3rd Floor Azure Corporation Trade Tower Starlight Sarkhej, Ahmedabad Gujarat 380042",
                            },
                            {
                              "id": "4",
                              "title": "Zommunities heritage Pvt. Ltd",
                              "subtitle":
                                  "A-Block, 5th Floor, WTT, World Trade Tower, Makarba, Sarkhej, Ahmedabad Gujarat 380051",
                            },
                            {
                              "id": "5",
                              "title": "Aelta Corporation Pvt. Ltd",
                              "subtitle":
                                  "A-305 3rd Floor Azure Corporation Trade Tower Starlight Sarkhej, Ahmedabad Gujarat 380042",
                            },
                            {
                              "id": "6",
                              "title": "Jommunities heritage Pvt. Ltd",
                              "subtitle":
                                  "A-Block, 5th Floor, WTT, World Trade Tower, Makarba, Sarkhej, Ahmedabad Gujarat 380051",
                            },
                          ],
                        ),
                  );
                },
              ),
              const SizedBox(height: 50),
              MyCoButton(
                title: "Otp BottomSheet",
                boarderRadius: 50,
                isShadowTopRight: true,
                backgroundColor: Colors.cyan.shade200,
                onTap: () {
                  showCustomEmailVerificationSheet(
                    context: context,
                    emailAddress: '',
                    onSubmit: (String otp) {},
                    onResend: () {},
                    onVerifyButtonPressed: () {},
                    length: 6,
                  );
                },
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "Otp  Dialogue",
                boarderRadius: 50,
                onTap: () {
                  showCustomEmailVerificationSheet(
                    isDialog: true,
                    context: context,
                    emailAddress: '',
                    onSubmit: (String otp) {},
                    onResend: () {},
                    onVerifyButtonPressed: () {},
                    length: 4,
                  );
                },
              ),
              const SizedBox(height: 50),

              MyCoButton(
                title: "Calender",
                boarderRadius: 50,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return CustomCalendar();
                    },
                  );
                },
              ),
              const SizedBox(height: 50),

              Container(
                height: 50,
                width: double.infinity,
                color: Colors.amberAccent,
                child: Marquee(
                  text: '🔥 Welcome to Flutter Marquee Widget Example! 🚀   ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  // scrollAxis: Axis.horizontal,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 60.0,
                  velocity: 100.0,
                  // pauseAfterRound: Duration(seconds: 1),
                  // startPadding: 10.0,
                  // accelerationDuration: Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  // decelerationDuration: Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              const SizedBox(height: 20),
              MyCoButton(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerPage(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      scannedResult = result;
                      log('Scanned Data: $result');
                    });
                  }
                },
                title: scannedResult,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DialDatePickerWidget(
                      // minDate: DateTime(2020, 1),
                      // maxDate: DateTime(2026, 12),
                      initialDate: DateTime(2025, 5, 26),
                      timePicker: true,
                      // use24hFormat: true,
                      pickDay: false,
                      onSubmit: (date) {
                        log('User selected: $date');
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DialDatePickerWidget(
                      // minDate: DateTime(2020, 1),
                      // maxDate: DateTime(2026, 12),
                      initialDate: DateTime(2025, 5, 26),
                      // pickDay: false,
                      onSubmit: (date) {
                        debugPrint('User selected: $date');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ExpandableText(
                shortText: 'This is a preview of the text',
                longText:
                    ' that is initially visible. Here is the additional content that becomes visible when expanded.',
              ),
              const SizedBox(height: 20),
              CurrentOpeningCard(
                boxColor: AppColors.GPSMediumColor,
                title: 'Vatsal Sir CHPL',
                position: 'Jr. Android Developer',
                status: 'PENDING',
                mail: 'mauliknagvdiya@gmail.com',
                number: 1234567890,
                submittedDate: DateTime(2002, 4, 5),
                isCancelShow: true,
                onCancelTap: () => log('Cancel Tap'),
              ),
              const SizedBox(height: 20),
              CurrentOpeningCard(
                boxColor: AppColors.primary,
                title: 'Vatsal Sir CHPL',
                position: 'Jr. Android Developer',
                status: 'CANCELED',
                mail: 'mauliknagvdiya@gmail.com',
                number: 1234567890,
                submittedDate: DateTime(2002, 4, 5),
              ),
              const SizedBox(height: 20),
              WorkReportAdd(
                isRequired: true,
                forTitle: 'PunchIn',
                title: 'Work Report Title',
                isAddButtonShow: true,
                onAddTap: () => log('Add Clicked'),
                onNextTap: () => log('View Report Clicked'),
              ),
              const SizedBox(height: 20),
              WorkReportHistory(
                reportDate: DateTime(2025, 5, 15),
                title: 'Work Report Title',
                submittedOn: DateTime(2024, 11, 29, 18, 20),
                onDownloadTap: () => log('Download Clicked'),
                onNextTap: () => log('View Report Clicked'),
              ),
              const SizedBox(height: 20),
              LeaveDetailsCard(
                color: AppColors.error,
                suffixIcon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                ),
                titleDate: DateTime(2025, 6, 2),
                leaveDate: DateTime(2025, 5, 22),
                leaveType: 'Full Day',
                reason: 'Attending personal work',
                location:
                    '101, Sanand - Sarkhej Rd, Makarba, Ahmedabad, Gujarat 382210, India',
                createdOn: DateTime(2025, 1, 20, 10),
                approvedOn: DateTime(2025, 1, 20, 11),
                approvedBy: 'Mukund Madhav',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
