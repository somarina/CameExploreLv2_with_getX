part of 'hotel_detail_screen_view.dart';

class HotelDetailScreenViewController extends GetxController {
  final currentIndex = 0.obs;
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void showNearbyBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),

            Text(
              "Nearby & Popular places",
              style: GoogleFonts.googleSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 20),
            Divider(height: 1),

            Expanded(
              child: ListView(
                padding: EdgeInsets.all(24),
                children: [
                  _buildSectionTitle("Popular places"),

                  SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return _buildPlaceItem();
                    },
                  ),

                  SizedBox(height: 20),

                  _buildSectionTitle("Nearby places"),

                  SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return _buildPlaceItem();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.googleSans(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildPlaceItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xffE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Text(
              "Farm Link",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          const Text(
            "770 m",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
