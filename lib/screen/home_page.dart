import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/custom_active_assets.dart';
import 'package:myco_karan/custom_widgets/custom_calender.dart';
import '../custom_widgets/bottomsheet_otp.dart';
import '../custom_widgets/bottomsheet_radio_btn.dart';
import '../custom_widgets/bottomsheet_travel_mode.dart';
import '../custom_widgets/custom_all_assets.dart';
import '../custom_widgets/custom_assets_history.dart';
import '../custom_widgets/custom_assets_holder.dart';
import '../custom_widgets/custom_past_assets.dart';
import '../custom_widgets/new_myco_button.dart';
import '../main.dart';
import '../maulik_file/current_opening_card.dart';
import '../maulik_file/wfh_box.dart';
import '../maulik_file/work_report_add_box.dart';
import '../maulik_file/work_report_history_box.dart';
import '../themes_colors/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageGridPreviewWidget(
                  imageList: [
                    "https://www.shutterstock.com/image-photo/very-random-pose-asian-men-260nw-2423213779.jpg",
                    "https://media.istockphoto.com/id/178967977/photo/mature-african-man-laughing.jpg?s=612x612&w=0&k=20&c=uAbwJFQCjzQBUgy4Z003iY_HA94VK50iTbxsOl_UoRc=",
                    "https://plus.unsplash.com/premium_photo-1682000436148-88a145551f50?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8ZHVsbHxlbnwwfHwwfHx8MA%3D%3D",
                    "https://media.istockphoto.com/id/1618846975/photo/smile-black-woman-and-hand-pointing-in-studio-for-news-deal-or-coming-soon-announcement-on.jpg?s=612x612&w=0&k=20&c=LUvvJu4sGaIry5WLXmfQV7RStbGG5hEQNo8hEFxZSGY=",
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxglj3iwmlB9Y9oZBH3qicAgZcnj6dtdHN2Q&s",
                    "https://www.shutterstock.com/image-photo/very-random-pose-asian-men-260nw-2423213779.jpg",
                    "https://www.shutterstock.com/image-photo/handsome-indonesian-southeast-asian-man-260nw-2476654675.jpg",
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
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BottomsheetRadioButton(
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

              // ////////////////////////////////////////////////////////////////////
              MyCoButton(
                title: "Otp BottomSheet",
                boarderRadius: 50,
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
                title: "Press meeee for otp  dialogue",
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
                title: "Press meeee for calender",
                boarderRadius: 50,
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
                        content: CustomCalendar(
                          totalPreviousYear: 0,
                          totalNextYear: 0,
                          isRangeSelectionMode: true,
                          preselectSaturdays: true,
                          preselectSundays: true,
                          customDatesAsSelected: [
                            DateTime(2025, 6, 2),
                            DateTime(2025, 6, 10),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 50),

              // Active & Past Assets
              CustomActiveAssets(
                title: 'Desktop',
                code: 'AS100',
                imageUrl: 'assets/laptop.png',
                brand: 'Acer',
                serial: 'NXKSSDSDSDS12121212',
                handover: '02-05-2025',
                gradientContainerColor: [Colors.teal.shade300, Colors.teal],
              ),
              const SizedBox(height: 50),
              CustomPastAssets(
                title: 'Laptop',
                code: 'LTP-0021',
                imageUrl: 'assets/mail.png',
                brand: 'Dell Latitude 5490',
                serial: 'DLT5490SN2023',
                handoverDate: '2023-05-10',
                takeoverDate: '2025-02-12',
                gradientContainerColor: [Color(0xFF29B6F6), Color(0xFF0288D1)],
              ),
              CustomAllAssets(
                title: 'Mobile Phone',
                code: 'MOB-0034',
                imageUrl: 'assets/mail.png',
                brand: 'Samsung Galaxy S21',
                serial: 'SGS21SN2023',
                handover: '2023-06-15',
                gradientContainerColor: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                onEdit: () {},
                onQRCode: () {},
                onViewDetails: () {},
                category: 'Electronics',
              ),
              const SizedBox(height: 50),
              CustomAssetsHolder(
                userName: "Mukund Madhav",
                designation: "QA",
                location: "QA Technical - Junagadh",
                title: "HP AS112",
                brand: "Acer",
                serial: "NXKSSDSDSDS12121212",
                handoverDate: "02-05-2025",
                gradientContainerColor: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                imageUrl: 'assets/laptop.png',
                onViewMore: () {},
              ),
              const SizedBox(height: 50),
              CustomAssetsHistory(
                gradientContainerColor: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                userName: "Mukund Madhav",
                designation: "QA",
                location: "QA Technical - Junagadh",
                takeoverDate: "18-02-2025",
                handoverDate: "20-05-2025",
                onViewMore: () {},
              ),
              const SizedBox(height: 20),
              MyCoButton(boarderRadius: 50, title: 'Testing', onTap: () {}),
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
                suffixIcon: const Icon(Icons.close_rounded, color: AppColors.white),
                titleDate: DateTime(2025, 6, 2),
                leaveDate: DateTime(2025, 5, 22),
                leaveType: 'Full Day',
                reason: 'Attending personal work',
                location: '101, Sanand - Sarkhej Rd, Makarba, Ahmedabad, Gujarat 382210, India',
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

