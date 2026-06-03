import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'help_support_screen_binding.dart';
part 'help_support_screen_controller.dart';

class HelpSupportScreenView extends GetView<HelpSupportScreenViewController> {
  const HelpSupportScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "condition".tr,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description_outlined, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            "terms_of_use".tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            Text(
                              "last_updated",
                              style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "១. ការទទួលយកលក្ខខណ្ឌ",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "ដោយការចូលប្រើកម្មវិធីនេះ អ្នកយល់ព្រមទទួលយកលក្ខខណ្ឌទាំងនេះ។ ប្រសិនបើអ្នកមិនយល់ព្រមជាមួយលក្ខខណ្ឌទាំងនេះទេ សូមកុំប្រើកម្មវិធី។",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_title".tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_desc".tr,
                        style: GoogleFonts.spaceGrotesk(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "២. ការប្រើប្រាស់កម្មវិធី",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "អ្នកយល់ព្រមថា:",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " នឹងប្រើកម្មវិធីក្នុងគោលបំណងស្របច្បាប់ប៉ុណ្ណោះ\n នឹងមិនរំលោភបំពានសិទ្ធិអ្នកប្រើផ្សេងទៀត\n នឹងមិនផ្ញើមាតិកាមិនសមរម្យ\n នឹងរក្សាទុកព័ត៌មានគណនីរបស់អ្នកឱ្យមានសុវត្ថិភាព",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "៣. ភាពឯកជន",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "យើងយកចិត្តទុកដាក់ខ្លាំងចំពោះភាពឯកជនរបស់អ្នក។ ព័ត៌មានផ្ទាល់ខ្លួនរបស់អ្នកនឹងត្រូវបានរក្សាទុកដោយសុវត្ថិភាព និងនឹងមិនត្រូវបានចែករំលែកជាមួយភាគីទីបីដោយមិនមានការយល់ព្រមរបស់អ្នកនោះទេ។",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "៤. កម្មសិទ្ធិបញ្ញា",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "មាតិកាទាំងអស់នៅក្នុងកម្មវិធីនេះ រួមទាំងប៉ុន្តែមិនកំណត់ចំពោះអត្ថបទ រូបភាព និងកូដកម្មវិធី គឺជាកម្មសិទ្ធិរបស់យើង។",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "៥. ការកំណត់ទំនួលខុសត្រូវ",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "កម្មវិធីត្រូវបានផ្តល់ជូន 'តាមដែលមាន'។ យើងមិនធានាអំពីភាពពេញលេញ សុក្រិតភាព ឬភាពត្រឹមត្រូវនៃកម្មវិធីនោះទេ។",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "៦. ការផ្លាស់ប្តូរលក្ខខណ្ឌ",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "យើងរក្សាសិទ្ធិក្នុងការកែប្រែលក្ខខណ្ឌទាំងនេះគ្រប់ពេល។ ការប្រើប្រាស់បន្តរបស់អ្នកបន្ទាប់ពីការផ្លាស់ប្តូរនឹងត្រូវបានចាត់ទុកថាជាការទទួលយកការផ្លាស់ប្តូរទាំងនោះ។",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "៧. ទំនាក់ទំនង",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "ប្រសិនបើអ្នកមានសំណួរអំពីលក្ខខណ្ឌទាំងនេះ សូមទាក់ទងមកយើងតាមរយៈ support@camexplore.com",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ឯកសារពាក់ព័ន្ធ",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "គោលការណ៍ភាពឯកជន\nអានពីរបៀបដែលយើងប្រើប្រាស់ទិន្នន័យរបស់អ្នក",
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
